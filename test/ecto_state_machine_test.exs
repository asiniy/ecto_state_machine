defmodule EctoStateMachineTest do
  use ExUnit.Case, async: true

  alias Dummy.User

  import Dummy.Factories

  setup_all do
    {
      :ok,
      unconfirmed_user: insert(:user, %{ rules: "unconfirmed" }),
      confirmed_user:   insert(:user, %{ rules: "confirmed" }),
      blocked_user:     insert(:user, %{ rules: "blocked" }),
      admin:            insert(:user, %{ rules: "admin" })
    }
  end

  describe "events" do
    test "#confirm", context do
      changeset = User.confirm(context[:unconfirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "confirmed"
      assert Map.keys(changeset.changes) == ~w(confirmed_at rules)a

      changeset = User.confirm(context[:confirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :confirmed to :confirmed", []}]

      changeset = User.confirm(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :blocked to :confirmed", []}]

      changeset = User.confirm(context[:admin])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :admin to :confirmed", []}]
    end

    test "#block", context do
      changeset = User.block(context[:unconfirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :unconfirmed to :blocked", []}]

      changeset = User.block(context[:confirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "blocked"

      changeset = User.block(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :blocked to :blocked", []}]

      changeset = User.block(context[:admin])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "blocked"
    end

    test "#make_admin", context do
      changeset = User.make_admin(context[:unconfirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :unconfirmed to :admin", []}]

      changeset = User.make_admin(context[:confirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "admin"

      changeset = User.make_admin(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :blocked to :admin", []}]

      changeset = User.make_admin(context[:admin])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :admin to :admin", []}]
    end
  end

  describe "can_?" do
    test "#can_confirm?", context do
      assert User.can_confirm?(context[:unconfirmed_user])    == true
      assert User.can_confirm?(context[:confirmed_user])      == false
      assert User.can_confirm?(context[:blocked_user])        == false
      assert User.can_confirm?(context[:admin])               == false
    end

    test "#can_block?", context do
      assert User.can_block?(context[:unconfirmed_user])      == false
      assert User.can_block?(context[:confirmed_user])        == true
      assert User.can_block?(context[:blocked_user])          == false
      assert User.can_block?(context[:admin])                 == true
    end

    test "#can_make_admin?", context do
      assert User.can_make_admin?(context[:unconfirmed_user]) == false
      assert User.can_make_admin?(context[:confirmed_user])   == true
      assert User.can_make_admin?(context[:blocked_user])     == false
      assert User.can_make_admin?(context[:admin])            == false
    end
  end

  describe "#validate_rules_change" do
    test "valid state change", context do
      valid_transitions = [
        unconfirmed_user: "confirmed",
        confirmed_user:   "blocked",
        confirmed_user:   "admin",
        admin:            "blocked",
      ]

      valid_transitions |> Enum.each(fn {ctx, to} ->
        changeset = context[ctx] |> Ecto.Changeset.change(%{rules: to})
                    |> User.validate_rules_change
        assert changeset.valid? == true
      end)
    end

    test "invalid state change", context do
      invalid_transitions = [
        unconfirmed_user: {"unconfirmed", "blocked"},
        unconfirmed_user: {"unconfirmed", "admin"},
        confirmed_user:   {"confirmed",   "unconfirmed"},
        blocked_user:     {"blocked",     "confirmed"},
        blocked_user:     {"blocked",     "admin"},
        blocked_user:     {"blocked",     "confirmed"},
        blocked_user:     {"blocked",     "unconfirmed"},
        admin:            {"admin",       "confirmed"},
        admin:            {"admin",       "unconfirmed"},
      ]

      invalid_transitions |> Enum.each(fn {ctx, {from, to}} ->
        changeset = context[ctx] |> Ecto.Changeset.change(%{rules: to})
                                 |> User.validate_rules_change
        assert changeset.valid? == false
        assert changeset.errors == [rules: {"You can't move state from :#{from} to :#{to}", []}]
      end)
    end

    test "changeset with the same state", context do
      no_change_users = [
        unconfirmed_user: "unconfirmed",
        confirmed_user:   "confirmed",
        blocked_user:     "blocked",
        admin:            "admin",
      ]

      no_change_users |> Enum.each(fn {ctx, to} ->
        changeset = context[ctx] |> Ecto.Changeset.change(%{state: to})
                                 |> User.validate_rules_change
        assert changeset.valid? == true
      end)
    end

    test "changeset without a state change in the changeset" do
      changeset = %User{} |> Ecto.Changeset.change(%{other: "attribute"})
                          |> User.validate_rules_change
      assert changeset.valid? == true
    end
  end

  test "#states" do
    assert User.rules_states == [:unconfirmed, :confirmed, :blocked, :admin]
  end

  test "#events" do
    assert User.rules_events == [:confirm, :block, :make_admin]
  end
end
