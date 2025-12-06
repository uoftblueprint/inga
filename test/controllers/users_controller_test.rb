require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    create_logged_in_admin_user

    # Users for index filtering tests
    @user1 = create(:user, username: "super_user")
    @user2 = create(:user, username: "superbase_user")
    @user3 = create(:user, username: "other_user")
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

    assert_redirected_to root_path
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

  test "#index filters users by username" do
    get users_url, params: { username: "super" }
    
    assert_response :success
    
    assert_select "li", text: @user1.username, count: 1
    assert_select "li", text: @user2.username, count: 1
    assert_select "li", text: @user3.username, count: 0
  end

  test "#index filters users by partial match in middle" do
    get users_url, params: { username: "base" }

    assert_response :success

    assert_select "li", text: @user1.username, count: 0
    assert_select "li", text: @user2.username, count: 1
    assert_select "li", text: @user3.username, count: 0
  end

  test "#index filters users is not case sensitive" do
    get users_url, params: { username: "SUPER" }

    assert_response :success

    assert_select "li", text: @user1.username, count: 1
    assert_select "li", text: @user2.username, count: 1
    assert_select "li", text: @user3.username, count: 0
  end
end
