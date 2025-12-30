require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @user = create(:user)
  end

  [
    { route: "new", method: :get, url_helper: :new_user_url },
    { route: "create", method: :post, url_helper: :users_url },
    { route: "index", method: :get, url_helper: :users_url },
    { route: "edit", method: :get, url_helper: :edit_user_url },
    { route: "update", method: :patch, url_helper: :user_url },
    { route: "destroy", method: :delete, url_helper: :user_url }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      public_send(hash[:method], public_send(hash[:url_helper], @user))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user

      public_send(hash[:method], public_send(hash[:url_helper], @user))
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  [
    { route: "new", method: :get, url_helper: :new_user_url },
    { route: "index", method: :get, url_helper: :users_url },
    { route: "edit", method: :get, url_helper: :edit_user_url }
  ].each do |hash|
    test "##{hash[:route]} renders successfully when a user is an admin" do
      public_send(hash[:method], public_send(hash[:url_helper], @user))
      assert_response :success
    end
  end

  test "#index successfully renders a created user" do
    user = create(:user)
    get users_url

    assert_select "table tr", count: 4 do |rows|
      assert_select rows[-1], "td" do |cells|
        assert_equal user.username.to_s, cells[0].text.strip
      end
    end
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

  test "#create fails to create a user with invalid parameters" do
    create(:user, username: "existinguser")
    user_params = {
      username: "existinguser",
      password: "password",
      password_confirmation: "differentpassword"
    }

    post users_url, params: { user: user_params }
    assert_flashed :error
  end

  test "#update successfully destroys a user's roles when none are provided" do
    @user.roles = %w[admin reporter]

    patch user_url(@user), params: { user: { username: @user.username, roles: ["admin"] } }
    assert_redirected_to users_path
    assert_not_includes @user.reload.user_roles.pluck(:role), "reporter"
  end

  test "#destroy prevents self-deletion" do
    user = create_logged_in_admin_user
    delete user_url(user)
    assert_flashed :error
  end

  test "#destroy successfully deletes another user" do
    user_to_delete = create(:user)

    delete user_url(user_to_delete)
    assert_redirected_to users_path
    assert_not User.exists?(user_to_delete.id)
    assert_flashed :success
  end
end
