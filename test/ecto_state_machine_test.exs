defmodule EctoStateMachineTest do
  use EctoStateMachine.EctoCase, async: true
  use ExSpec, async: true

  alias EctoStateMachine.{User, UserWithInitial}
  import EctoStateMachine.TestFactory

  setup_all do
    {
      :ok,
      unconfirmed_user: insert(:user, %{ state: "unconfirmed" }),
      confirmed_user:   insert(:user, %{ state: "confirmed" }),
      blocked_user:     insert(:user, %{ state: "blocked" }),
      admin:            insert(:user, %{ state: "admin" }),
      initial_user:     insert(:user, %{ state: ""}),
      not_found_state:  insert(:user, %{ state: "some"})
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
        assert_raise RuntimeError, "You can't move state from :admin to :confirmed", fn ->
          apply(UserWithInitial, method, [context[:initial_user]])
        end

        assert_raise RuntimeError, "You can't move state from :admin to :confirmed", fn ->
          apply(UserWithInitial, method, [context[:not_found_state]])
        end

        assert_raise RuntimeError, "You can't move state from :nil to :confirmed", fn ->
          apply(User, method, [context[:initial_user]])
        end

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

      it "#block! with initials", context do
        model = UserWithInitial.block!(context[:initial_user])
        assert model.state == "blocked"

        model = UserWithInitial.block!(context[:not_found_state])
        assert model.state == "blocked"
      end

      it "#block", context do
        cs = User.block(context[:confirmed_user])
        assert cs.changes.state == "blocked"

        cs = User.block(context[:admin])
        assert cs.changes.state == "blocked"

        check_block_errors(context, :block)
      end

      it "#block with initials", context do
        cs = UserWithInitial.block(context[:initial_user])
        assert cs.changes.state == "blocked"

        cs = UserWithInitial.block(context[:not_found_state])
        assert cs.changes.state == "blocked"
      end

      defp check_block_errors(context, method \\ :block!) do
        assert_raise RuntimeError, "You can't move state from :unconfirmed to :blocked", fn ->
          apply(UserWithInitial, method, [context[:unconfirmed_user]])
        end

        assert_raise RuntimeError, "You can't move state from :blocked to :blocked", fn ->
          apply(UserWithInitial, method, [context[:blocked_user]])
        end

        assert_raise RuntimeError, "You can't move state from :nil to :blocked", fn ->
          apply(User, method, [context[:initial_user]])
        end

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
        assert_raise RuntimeError, "You can't move state from :admin to :admin", fn ->
          apply(UserWithInitial, method, [context[:initial_user]])
        end

        assert_raise RuntimeError, "You can't move state from :admin to :admin", fn ->
          apply(UserWithInitial, method, [context[:not_found_state]])
        end

        assert_raise RuntimeError, "You can't move state from :nil to :admin", fn ->
          apply(User, method, [context[:initial_user]])
        end

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
    context "without initial" do
      it "#can_confirm?", context do
        can_confirm?(context)
        assert User.can_confirm?(context[:initial_user]) == false
        assert User.can_confirm?(context[:not_found_state]) == false
      end

      it "#can_block?", context do
        can_block?(context)
        assert User.can_block?(context[:initial_user]) == false
        assert User.can_block?(context[:not_found_state]) == false
      end

      it "#can_make_admin?", context do
        can_make_admin?(context)
        assert User.can_make_admin?(context[:initial_user]) == false
        assert User.can_make_admin?(context[:not_found_state]) == false
      end
    end

    context "with initial" do
      it "#can_confirm?", context do
        can_confirm?(context, UserWithInitial)
        assert UserWithInitial.can_confirm?(context[:initial_user]) == false
        assert UserWithInitial.can_confirm?(context[:not_found_state]) == false
      end

      it "#can_block?", context do
        can_block?(context, UserWithInitial)
        assert UserWithInitial.can_block?(context[:initial_user]) == true
        assert UserWithInitial.can_block?(context[:not_found_state]) == true
      end

      it "#can_make_admin?", context do
        can_make_admin?(context, UserWithInitial)
        assert UserWithInitial.can_make_admin?(context[:initial_user]) == false
        assert UserWithInitial.can_make_admin?(context[:not_found_state]) == false
      end
    end

    defp can_confirm?(context, model \\ User) do
      assert model.can_confirm?(context[:unconfirmed_user]) == true
      assert model.can_confirm?(context[:confirmed_user])   == false
      assert model.can_confirm?(context[:blocked_user])     == false
      assert model.can_confirm?(context[:admin])            == false
    end

    defp can_block?(context, model \\ User) do
      assert model.can_block?(context[:unconfirmed_user]) == false
      assert model.can_block?(context[:confirmed_user])   == true
      assert model.can_block?(context[:blocked_user])     == false
      assert model.can_block?(context[:admin])            == true
    end

    defp can_make_admin?(context, model \\ User) do
      assert model.can_make_admin?(context[:unconfirmed_user]) == false
      assert model.can_make_admin?(context[:confirmed_user])   == true
      assert model.can_make_admin?(context[:blocked_user])     == false
      assert model.can_make_admin?(context[:admin])            == false
    end
  end
end
