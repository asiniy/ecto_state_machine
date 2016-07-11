defmodule EctoStateMachineTest do
  use EctoStateMachine.EctoCase, async: true
  use ExSpec, async: true

  alias EctoStateMachine.User
  import EctoStateMachine.TestFactory

  setup_all do
    {
      :ok,
      unconfirmed_user: insert(:user, %{ state: "unconfirmed" }),
      confirmed_user:   insert(:user, %{ state: "confirmed" }),
      blocked_user:     insert(:user, %{ state: "blocked" }),
      admin:            insert(:user, %{ state: "admin" })
    }
  end

  describe "events" do
    context "#confirm" do
      it "#confirm!", context do
        model = User.confirm!(context[:unconfirmed_user])
        assert model.state == "confirmed"

        check_confirm_errors(context)
      end

      it "#confirm", context do
        cs = User.confirm(context[:unconfirmed_user])
        assert cs.changes.state == "confirmed"

        check_confirm_errors(context, :confirm)
      end

      defp check_confirm_errors(context, method \\ :confirm!) do
        assert_raise RuntimeError, "You can't move state from :confirmed to :confirmed", fn ->
          apply(User, method, [context[:confirmed_user]])
        end

        assert_raise RuntimeError, "You can't move state from :blocked to :confirmed", fn ->
          apply(User, method, [context[:blocked_user]])
        end

        assert_raise RuntimeError, "You can't move state from :admin to :confirmed", fn ->
          apply(User, method, [context[:admin]])
        end
      end
    end

    context "#block" do
      it "#block!", context do
        model = User.block!(context[:confirmed_user])
        assert model.state == "blocked"

        model = User.block!(context[:admin])
        assert model.state == "blocked"

        check_block_errors(context)
      end

      it "#block", context do
        cs = User.block(context[:confirmed_user])
        assert cs.changes.state == "blocked"

        cs = User.block(context[:admin])
        assert cs.changes.state == "blocked"

        check_block_errors(context, :block)
      end

      defp check_block_errors(context, method \\ :block!) do
        assert_raise RuntimeError, "You can't move state from :unconfirmed to :blocked", fn ->
          apply(User, method, [context[:unconfirmed_user]])
        end

        assert_raise RuntimeError, "You can't move state from :blocked to :blocked", fn ->
          apply(User, method, [context[:blocked_user]])
        end
      end
    end

    context "#make_admin" do
      it "#make_admin!", context do
        model = User.make_admin!(context[:confirmed_user])
        assert model.state == "admin"

        check_admin_errors(context)
      end

      it "#make_admin", context do
        cs = User.make_admin(context[:confirmed_user])
        assert cs.changes.state == "admin"

        check_admin_errors(context, :make_admin)
      end

      defp check_admin_errors(context, method \\ :make_admin!) do
        assert_raise RuntimeError, "You can't move state from :unconfirmed to :admin", fn ->
          apply(User, method, [context[:unconfirmed_user]])
        end

        assert_raise RuntimeError, "You can't move state from :blocked to :admin", fn ->
          apply(User, method, [context[:blocked_user]])
        end

        assert_raise RuntimeError, "You can't move state from :admin to :admin", fn ->
          apply(User, method, [context[:admin]])
        end
      end
    end
  end

  describe "can_?" do
    it "#can_confirm?", context do
      assert User.can_confirm?(context[:unconfirmed_user]) == true
      assert User.can_confirm?(context[:confirmed_user])   == false
      assert User.can_confirm?(context[:blocked_user])     == false
      assert User.can_confirm?(context[:admin])            == false
    end

    it "#can_block?", context do
      assert User.can_block?(context[:unconfirmed_user]) == false
      assert User.can_block?(context[:confirmed_user])   == true
      assert User.can_block?(context[:blocked_user])     == false
      assert User.can_block?(context[:admin])            == true
    end

    it "#can_make_admin?", context do
      assert User.can_make_admin?(context[:unconfirmed_user]) == false
      assert User.can_make_admin?(context[:confirmed_user])   == true
      assert User.can_make_admin?(context[:blocked_user])     == false
      assert User.can_make_admin?(context[:admin])            == false
    end
  end
end
