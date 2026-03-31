require "test_helper"

class LogEntriesControllerTest < ActionDispatch::IntegrationTest
  test "#new redirects to login when unauthenticated" do
    get new_log_entry_url

    assert_response :redirect
    assert_redirected_to login_path
  end

  test "#new redirects admins to projects" do
    create_logged_in_admin_user

    get new_log_entry_url

    assert_response :redirect
    assert_redirected_to projects_path
  end

  test "#new renders for reporters" do
    reporter = create(:user, :reporter)
    post login_url, params: { username: reporter.username, password: reporter.password }

    get new_log_entry_url

    assert_response :success
  end
end
