defmodule EctoStateMachineTest do
  use ExUnit.Case, async: true
  use ExSpec,      async: true

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
    it "#confirm", context do
      changeset = Dummy.User.confirm(context[:unconfirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "confirmed"
      assert Map.keys(changeset.changes) == ~w(confirmed_at rules)a

      changeset = Dummy.User.confirm(context[:confirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :confirmed to :confirmed", []}]

      changeset = Dummy.User.confirm(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :blocked to :confirmed", []}]

      changeset = Dummy.User.confirm(context[:admin])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :admin to :confirmed", []}]
    end

    it "#block", context do
      changeset = Dummy.User.block(context[:unconfirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :unconfirmed to :blocked", []}]

      changeset = Dummy.User.block(context[:confirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "blocked"

      changeset = Dummy.User.block(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :blocked to :blocked", []}]

      changeset = Dummy.User.block(context[:admin])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "blocked"
    end

    it "#make_admin", context do
      changeset = Dummy.User.make_admin(context[:unconfirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :unconfirmed to :admin", []}]

      changeset = Dummy.User.make_admin(context[:confirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.rules     == "admin"

      changeset = Dummy.User.make_admin(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :blocked to :admin", []}]

      changeset = Dummy.User.make_admin(context[:admin])
      assert changeset.valid? == false
      assert changeset.errors == [rules: {"You can't move state from :admin to :admin", []}]
    end
  end

  describe "can_?" do
    it "#can_confirm?", context do
      assert Dummy.User.can_confirm?(context[:unconfirmed_user])    == true
      assert Dummy.User.can_confirm?(context[:confirmed_user])      == false
      assert Dummy.User.can_confirm?(context[:blocked_user])        == false
      assert Dummy.User.can_confirm?(context[:admin])               == false
    end

    it "#can_block?", context do
      assert Dummy.User.can_block?(context[:unconfirmed_user])      == false
      assert Dummy.User.can_block?(context[:confirmed_user])        == true
      assert Dummy.User.can_block?(context[:blocked_user])          == false
      assert Dummy.User.can_block?(context[:admin])                 == true
    end

    it "#can_make_admin?", context do
      assert Dummy.User.can_make_admin?(context[:unconfirmed_user]) == false
      assert Dummy.User.can_make_admin?(context[:confirmed_user])   == true
      assert Dummy.User.can_make_admin?(context[:blocked_user])     == false
      assert Dummy.User.can_make_admin?(context[:admin])            == false
    end
  end
end
