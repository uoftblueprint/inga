require "test_helper"

class UserRoleTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @user_role = create(:admin_role, user: @user)
  end

  test "should belong to user" do
    assert_respond_to @user_role, :user
    assert_instance_of User, @user_role.user
  end

  test "should have valid enum values" do
    assert_includes UserRole.roles.keys, "admin"
    assert_includes UserRole.roles.keys, "reporter"
    assert_includes UserRole.roles.keys, "analyst"
  end

  test "should validate uniqueness of role scoped to user" do
    duplicate_role = @user.user_roles.build(role: "admin")

    assert_not duplicate_role.valid?
    assert_includes duplicate_role.errors[:role], "has already been taken"
  end

  test "should allow same role for different users" do
    other_user = create(:user)
    other_user_role = other_user.user_roles.build(role: "admin")

    assert other_user_role.valid?
  end

  test "should allow different roles for same user" do
    reporter_role = @user.user_roles.build(role: "reporter")

    assert reporter_role.valid?
  end

  test "should raise ArgumentError for invalid role" do
    assert_raises(ArgumentError) do
      @user.user_roles.create!(role: "invalid_role")
    end
  end
end
