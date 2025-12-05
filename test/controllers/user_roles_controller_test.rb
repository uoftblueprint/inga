require "test_helper"

class UserRolesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    create_logged_in_admin_user
  end

  test "#create redirects to login route when a user is not authenticated" do
    log_out_user

    post user_user_roles_url(@user), params: { user_role: { role: "admin" } }
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "#create redirects to root route when a user is not authorized" do
    create_logged_in_user

    post user_user_roles_url(@user), params: { user_role: { role: "admin" } }
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "#create adds a role to a user successfully" do
    assert_difference("UserRole.count", 1) do
      post user_user_roles_url(@user), params: { user_role: { role: "admin" } }
    end

    assert_redirected_to root_path
    assert_equal "Role added successfully.", flash[:success]
    assert @user.reload.has_roles?(:admin)
  end

  test "#create does not add duplicate role to user" do
    create(:admin_role, user: @user)

    assert_no_difference("UserRole.count") do
      post user_user_roles_url(@user), params: { user_role: { role: "admin" } }
    end

    assert_redirected_to root_path
    assert flash[:error].present?
  end

  test "#create handles invalid role" do
    assert_no_difference("UserRole.count") do
      post user_user_roles_url(@user), params: { user_role: { role: "invalid_role" } }
    end

    assert_redirected_to root_path
    assert flash[:error].present?
  end
end
