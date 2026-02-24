require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @report = create(:report)
  end

  test "#index redirects to login route when a user is not authenticated" do
    log_out_user
    get reports_url
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "#index redirects to root route when a user is not authorized" do
    create_logged_in_user
    get reports_url
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "#index renders successfully when a user is an admin" do
    get reports_url
    assert_response :success
  end

  test "#destroy successfully deletes a report when user is an admin" do
    assert_difference("Report.count", -1) do
      delete report_path(@report)
    end

    assert_redirected_to reports_path
  end
end
