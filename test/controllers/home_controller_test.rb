require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "#index redirects unauthenticated users to login with a flash" do
    get root_url

    assert_response :redirect
    assert_redirected_to login_path
    assert_equal I18n.t("application_controller.require_login.error"), flash[:error]
  end

  test "#index renders reporter dashboard for reporters" do
    create_logged_in_user_with_roles(:reporter)

    get root_url

    assert_response :success
    assert_select "h1", text: I18n.t("reporter_dashboard.show.title")
    assert_select "a[href='#{new_journal_path}']", text: I18n.t("reporter_dashboard.show.actions.new_journal")
    assert_select "a[href='#{new_log_entry_path}']", text: I18n.t("reporter_dashboard.show.actions.new_log_entry")
  end

  test "#index redirects admins to projects" do
    create_logged_in_user_with_roles(:admin)

    get root_url

    assert_response :redirect
    assert_redirected_to projects_path
  end

  test "#index redirects analysts to reports" do
    create_logged_in_user_with_roles(:analyst)

    get root_url

    assert_response :redirect
    assert_redirected_to reports_path
  end

  test "#index renders reporter dashboard for analyst reporters" do
    create_logged_in_user_with_roles(:analyst, :reporter)

    get root_url

    assert_response :success
    assert_select "h1", text: I18n.t("reporter_dashboard.show.title")
  end

  test "#index redirects admin analysts to projects" do
    create_logged_in_user_with_roles(:admin, :analyst)

    get root_url

    assert_response :redirect
    assert_redirected_to projects_path
  end

  test "#index redirects authenticated users with no roles to login with an authorization flash" do
    create_logged_in_user_with_roles

    get root_url

    assert_response :redirect
    assert_redirected_to login_path
    assert_equal I18n.t("application_controller.check_required_roles.error"), flash[:error]

    get projects_url

    assert_response :redirect
    assert_redirected_to login_path
    assert_equal I18n.t("application_controller.require_login.error"), flash[:error]
  end
end
