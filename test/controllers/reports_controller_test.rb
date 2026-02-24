require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
  end

  [
    { route: "show", method: :get, url_helper: :report_url, needs_report: true }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      args = create(:report) if hash[:needs_report]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user

      args = create(:report) if hash[:needs_report]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to root_path
    end

    test "##{hash[:route]} renders successfully when a user is an admin" do
      args = create(:report) if hash[:needs_report]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :success
    end
  end

  test "#show renders the report correctly" do
    report = create(:report)
    journal = create(:journal)
    aggregated_datum = create(:aggregated_datum, report: report)

    report.journals << journal
    report.aggregated_data << aggregated_datum

    get report_path(report)
    assert_response :success

    assert_match journal.title, response.body
    assert_match journal.markdown_content.to_plain_text, response.body

    assert_match aggregated_datum.value.to_s, response.body
    assert_match aggregated_datum.additional_text, response.body
  end
end
