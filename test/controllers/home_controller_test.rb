require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "#index redirects reporters to reporter dashboard" do
    reporter = create(:user, :reporter)
    post login_url, params: { username: reporter.username, password: reporter.password }

    get root_url

    assert_response :redirect
    assert_redirected_to reporter_dashboard_path
  end

  test "#index redirects admins to projects" do
    create_logged_in_admin_user

    get root_url

    assert_response :redirect
    assert_redirected_to projects_path
  end
end
