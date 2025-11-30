require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "#new renders the new user form" do
    get new_user_path
    assert_response :success
  end

  test "#create creates a new user with valid params" do
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          username: "newuser",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Account created successfully.", flash[:success]
    assert_not_nil session[:user_id]
  end

  test "#create does not create user with invalid params" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          username: "",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_equal "Failed to create account.", flash[:error]
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
    assert_equal "Failed to create account.", flash[:error]
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
    assert_equal "Failed to create account.", flash[:error]
  end

  test "#show displays user profile" do
    user = create(:user)
    create_logged_in_admin_user

    get user_path(user)
    assert_response :success
  end
end
