require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, username: "testuser", password: "password")
  end

  test "Create redirects to root path when login is successful and sets user_id in session" do
    post login_path, params: {username: "testuser", password: "password"}

    assert_redirected_to root_path
    assert_equal "Logged in successfully.", flash[:success]
    assert_equal @user.id, session[:user_id]
  end

  test "Create redirects to login path when login fails" do
    post login_path, params: {username: "wronguser", password: "wrongpassword"}

    assert_redirected_to login_path
    assert_equal "Invalid username or password.", flash[:error]
    assert_nil session[:user_id]
  end

  test "Create does not allow login with wrong password" do
    post login_path, params: {username: "testuser", password: "wrongpassword"}

    assert_redirected_to login_path
    assert_equal "Invalid username or password.", flash[:error]
    assert_nil session[:user_id]
  end
end
