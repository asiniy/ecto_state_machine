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
      {:ok, changeset} = User.confirm(context[:unconfirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "confirmed"
      assert Map.keys(changeset.changes) == ~w(confirmed_at rules)a

      {:error, changeset} = User.confirm(context[:confirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :confirmed to :confirmed", []}]

      {:error, changeset} = User.confirm(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :blocked to :confirmed", []}]

      {:error, changeset} = User.confirm(context[:admin])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :admin to :confirmed", []}]
    end

    test "#block", context do
      {:error, changeset} = User.block(context[:unconfirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :unconfirmed to :blocked", []}]

      {:ok, changeset} = User.block(context[:confirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "blocked"

      {:error, changeset} = User.block(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :blocked to :blocked", []}]

      {:ok, changeset} = User.block(context[:admin])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "blocked"
    end

    test "#make_admin", context do
      {:error, changeset} = User.make_admin(context[:unconfirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :unconfirmed to :admin", []}]

      {:ok, changeset} = User.make_admin(context[:confirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "admin"

      {:error, changeset} = User.make_admin(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :blocked to :admin", []}]

      {:error, changeset} = User.make_admin(context[:admin])
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

  test "#states" do
    assert User.rules_states == [:unconfirmed, :confirmed, :blocked, :admin]
  end

  test "#events" do
    assert User.rules_events == [:confirm, :block, :make_admin]
  end
end
