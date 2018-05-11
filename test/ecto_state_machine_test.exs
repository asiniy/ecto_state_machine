defmodule EctoStateMachineTest do
  use ExUnit.Case, async: true

  alias Dummy.User
  alias Dummy.WritingStyle

  import Dummy.Factories

  describe "User" do
    setup do
      {
        :ok,
        unconfirmed_user: insert(:user, %{ rules: "unconfirmed" }),
        confirmed_user:   insert(:user, %{ rules: "confirmed" }),
        blocked_user:     insert(:user, %{ rules: "blocked" }),
        admin:            insert(:user, %{ rules: "admin" })
      }
    end

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

    test "#states" do
      assert User.rules_states == [:unconfirmed, :confirmed, :blocked, :admin]
    end

    test "#events" do
      assert User.rules_events == [:confirm, :block, :make_admin]
    end
  end

  describe "WritingStyle" do
    setup do
      [
        upcased: insert(:writing_style, state: "UPCASED"),
        camel_cased: insert(:writing_style, state: "camelCased")
      ]
    end

    test "upcase/1", %{upcased: upcased, camel_cased: camel_cased} do
      changeset = WritingStyle.upcase(camel_cased)
      assert changeset.valid? == true
      assert changeset.changes.state == "UPCASED"

      changeset = WritingStyle.upcase(upcased)
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :upcased to :upcased", []}]
    end

    test "camel_case/1", %{upcased: upcased, camel_cased: camel_cased} do
      changeset = WritingStyle.camel_case(camel_cased)
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :camel_cased to :camel_cased", []}]

      changeset = WritingStyle.camel_case(upcased)
      assert changeset.valid? == true
      assert changeset.changes.state == "camelCased"
    end

    test "can_upcase?/1", %{upcased: upcased, camel_cased: camel_cased} do
      assert WritingStyle.can_upcase?(camel_cased) == true
      assert WritingStyle.can_upcase?(upcased) == false
    end

    test "can_camel_case?/1", %{upcased: upcased, camel_cased: camel_cased} do
      assert WritingStyle.can_camel_case?(camel_cased) == false
      assert WritingStyle.can_camel_case?(upcased) == true
    end

    test "states" do
      assert WritingStyle.states == [:upcased, :camel_cased]
    end

    test "events" do
      assert WritingStyle.events == [:upcase, :camel_case]
    end
  end
end
