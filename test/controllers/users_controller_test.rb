require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    create_logged_in_admin_user
  end

  test "#new redirects to login route when a user is not authenticated" do
    log_out_user

    get new_user_url
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "#new redirects to root route when a user is not authorized" do
    create_logged_in_user

    get new_user_url
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "#new renders successfully when a user is an admin" do
    get new_user_url
    assert_response :success
  end

  test "#show redirects to login route when a user is not authenticated" do
    log_out_user

    get user_path(@user)
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "#show renders when a user is logged in" do
    get user_path(@user)
    assert_response :success
  end

  test "#show renders successfully when a non-admin is logged in" do
    create_logged_in_user

    get user_path(@user)
    assert_response :success
  end

  test "#create creates a new user with valid params" do
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          username: "newuser",
          password: "password123",
          password_confirmation: "password123",
          roles: ["admin"]
        }
      }
    end

    created_user = User.find_by(username: "newuser")
    assert_redirected_to user_path(created_user)
  end

  test "#create does not create user when password confirmation doesn't match" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          username: "newuser",
          password: "password123",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "#create does not create user with duplicate username" do
    create(:user, username: "existinguser")

    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          username: "existinguser",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
