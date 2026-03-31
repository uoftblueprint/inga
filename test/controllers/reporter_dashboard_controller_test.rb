require "test_helper"

class ReporterDashboardControllerTest < ActionDispatch::IntegrationTest
  test "#show redirects to login when a user is not authenticated" do
    get reporter_dashboard_url

    assert_response :redirect
    assert_redirected_to login_path
  end

  test "#show redirects admins to projects when a user is not authorized" do
    create_logged_in_admin_user

    get reporter_dashboard_url

    assert_response :redirect
    assert_redirected_to projects_path
  end

  test "#show renders successfully for reporters" do
    reporter = create(:user, :reporter)
    post login_url, params: { username: reporter.username, password: reporter.password }

    get reporter_dashboard_url

    assert_response :success
    assert_select "h1", text: I18n.t("reporter_dashboard.show.title")
    assert_select "a[href='#{new_journal_path}']", text: I18n.t("reporter_dashboard.show.actions.new_journal")
    assert_select "a[href='#{new_log_entry_path}']", text: I18n.t("reporter_dashboard.show.actions.new_log_entry")
  end
end