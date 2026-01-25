require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @user = create(:user)
  end

  [
    { route: "index", method: :get, url_helper: :users_url },
    { route: "new", method: :get, url_helper: :new_user_url },
    { route: "create", method: :post, url_helper: :users_url },
    { route: "show", method: :get, url_helper: :user_url, needs_user: true },
    { route: "edit", method: :get, url_helper: :edit_user_url, needs_user: true },
    { route: "update", method: :patch, url_helper: :user_url, needs_user: true },
    { route: "destroy", method: :delete, url_helper: :user_url, needs_user: true }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      args = create(:user) if hash[:needs_user]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user
      args = create(:user) if hash[:needs_user]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  [
    { route: "index", method: :get, url_helper: :users_url },
    { route: "new", method: :get, url_helper: :new_user_url },
    { route: "show", method: :get, url_helper: :user_url, needs_user: true },
    { route: "edit", method: :get, url_helper: :edit_user_url, needs_user: true }
  ].each do |hash|
    test "##{hash[:route]} renders successfully when a user is an admin" do
      args = create(:user) if hash[:needs_user]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :success
    end
  end

  test "#index successfully renders a created user" do
    other_user = create(:user, username: "otheruser")

    get users_url
    assert_response :success

    assert_select "div", text: @user.username
    assert_select "div", text: other_user.username
  end

  test "#show successfully renders user details" do
    get user_url(@user)
    assert_response :success

    assert_match @user.username, response.body
  end

  test "#create successfully creates a user with valid parameters" do
    user_params = {
      username: "newuser",
      password: "password",
      password_confirmation: "password",
      roles: %w[admin reporter]
    }

    post users_url, params: { user: user_params }
    assert_redirected_to users_path
    assert_equal I18n.t("users.create.success"), flash[:success]

    created_user = User.find_by(username: "newuser")
    assert created_user.authenticate("password")
    assert_equal %w[admin reporter], created_user.user_roles.pluck(:role)
  end

  test "#create does not create a user with invalid params" do
    assert_no_difference("User.count") do
      post users_url, params: { user: { username: "", password: "", password_confirmation: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "#create enforces uniqueness of username" do
    existing = create(:user, username: "uniqueuser")

    post users_url,
         params: { user: { username: existing.username, password: "password", password_confirmation: "password" } }

    assert_no_difference("User.count") do
      post users_url,
           params: { user: { username: existing.username, password: "password", password_confirmation: "password" } }
    end

    assert_response :unprocessable_entity
  end

  test "#update successfully updates a user's username" do
    updated_username = "Updated user"

    patch user_url(@user), params: { user: { username: updated_username } }

    assert_redirected_to users_path
    assert_equal updated_username, @user.reload.username
  end

  test "#update does not update a user with invalid params" do
    original_username = @user.username

    patch user_url(@user), params: { user: { username: "" } }

    assert_response :unprocessable_entity
    assert_equal original_username, @user.reload.username
  end

  test "#update enforces uniqueness of username" do
    existing_user = create(:user, username: "uniqueuser")
    original_name = @user.username

    patch user_url(@user), params: { user: { username: existing_user.username } }

    assert_response :unprocessable_entity
    assert_equal original_name, @user.reload.username
  end

  test "#update successfully destroys a user's roles when none are provided" do
    @user.roles = %w[admin reporter]

    patch user_url(@user), params: { user: { username: @user.username, roles: ["admin"] } }

    assert_redirected_to users_path
    assert_not_includes @user.reload.user_roles.pluck(:role), "reporter"
  end

  test "#destroy successfully deletes a user when user is an admin" do
    user_to_delete = create(:user)

    assert_difference("User.count", -1) do
      delete user_url(user_to_delete)
    end

    assert_redirected_to users_path
  end

  test "#destroy prevents self-deletion" do
    user = create_logged_in_admin_user
    delete user_url(user)
    assert_flashed :error
  end
end
