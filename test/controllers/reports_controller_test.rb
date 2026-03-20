require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
  end

  [
    { route: "index", method: :get, url_helper: :reports_url, needs_report: false },
    { route: "show", method: :get, url_helper: :report_url, needs_report: true },
    { route: "new", method: :get, url_helper: :new_report_url, needs_report: false },
    { route: "edit", method: :get, url_helper: :edit_report_url, needs_report: true },
    { route: "update", method: :patch, url_helper: :report_url, needs_report: true },
    { route: "destroy", method: :delete, url_helper: :report_url, needs_report: true }
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
  end

  [
    { route: "show", method: :get, url_helper: :report_url, needs_report: true },
    { route: "new", method: :get, url_helper: :new_report_url, needs_report: false },
    { route: "edit", method: :get, url_helper: :edit_report_url, needs_report: true }
  ].each do |hash|
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

  test "#index displays reports" do
    report = create(:report)

    get reports_path
    assert_response :success
    assert_match I18n.l(report.start_date.to_date), response.body
    assert_match I18n.l(report.end_date.to_date), response.body
  end

  test "#new displays projects when valid dates are provided" do
    subproject = create(:subproject)
    create(:log_entry, subproject: subproject, created_at: 1.day.ago)

    get new_report_path, params: { start_date: 2.days.ago.to_date.to_s, end_date: Time.zone.today.to_s }
    assert_response :success
    assert_match subproject.project.name, response.body
  end

  test "#new displays subprojects when projects are selected" do
    subproject = create(:subproject)
    create(:log_entry, subproject: subproject, created_at: 1.day.ago)

    get new_report_path, params: {
      start_date: 2.days.ago.to_date.to_s,
      end_date: Time.zone.today.to_s,
      project_ids: [subproject.project.id]
    }
    assert_response :success
    assert_match subproject.name, response.body
  end

  test "#new handles invalid dates gracefully" do
    get new_report_path, params: { start_date: "invalid", end_date: "also-invalid" }
    assert_response :success
  end

  test "#new includes log entries from end date" do
    subproject = create(:subproject)
    create(:log_entry, subproject: subproject, created_at: Time.zone.today.noon)

    get new_report_path, params: {
      start_date: 2.days.ago.to_date.to_s,
      end_date: Time.zone.today.to_s,
      project_ids: [subproject.project.id]
    }
    assert_response :success
    assert_match subproject.name, response.body
  end

  test "#create redirects to login route when a user is not authenticated" do
    log_out_user

    post reports_url,
         params: { start_date: Time.zone.yesterday.to_s, end_date: Time.zone.today.to_s, subproject_ids: [1] }
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "#create redirects to root route when a user is not authorized" do
    create_logged_in_user

    post reports_url,
         params: { start_date: Time.zone.yesterday.to_s, end_date: Time.zone.today.to_s, subproject_ids: [1] }
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "#create creates a report and redirects on success" do
    subproject = create(:subproject)
    create(:log_entry, subproject: subproject, created_at: 1.day.ago)
    journal = create(:journal, subproject: subproject, created_at: 1.day.ago)

    assert_difference("Report.count", 1) do
      post reports_path, params: {
        start_date: 2.days.ago.to_date.to_s,
        end_date: Time.zone.today.to_s,
        subproject_ids: [subproject.id]
      }
    end

    report = Report.last
    assert_redirected_to edit_report_path(report)
    assert_equal I18n.t("reports.create.success"), flash[:success]
    assert_includes report.journals, journal
  end

  test "#create redirects with error when dates are missing" do
    assert_no_difference("Report.count") do
      post reports_path, params: { subproject_ids: [1] }
    end

    assert_redirected_to new_report_path
    assert_equal I18n.t("reports.create.invalid"), flash[:error]
  end

  test "#create redirects with error when dates are invalid" do
    assert_no_difference("Report.count") do
      post reports_path, params: { start_date: "invalid", end_date: "invalid", subproject_ids: [1] }
    end

    assert_redirected_to new_report_path
    assert_equal I18n.t("reports.create.invalid"), flash[:error]
  end

  test "#create redirects with error when subproject_ids are missing" do
    assert_no_difference("Report.count") do
      post reports_path, params: { start_date: Time.zone.yesterday.to_s, end_date: Time.zone.today.to_s }
    end

    assert_redirected_to new_report_path
    assert_equal I18n.t("reports.create.invalid"), flash[:error]
  end

  test "#create redirects with error when subproject_ids do not exist" do
    assert_no_difference("Report.count") do
      post reports_path, params: {
        start_date: Time.zone.yesterday.to_s,
        end_date: Time.zone.today.to_s,
        subproject_ids: [0]
      }
    end

    assert_redirected_to new_report_path
    assert_equal I18n.t("reports.create.invalid"), flash[:error]
  end

  test "#destroy redirects to login route when a user is not authenticated" do
    report = create(:report)
    log_out_user

    delete report_path(report)
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "#destroy redirects to root route when a user is not authorized" do
    report = create(:report)
    create_logged_in_user

    delete report_path(report)
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "#destroy removes the report and redirects to index" do
    report = create(:report)

    assert_difference("Report.count", -1) do
      delete report_path(report)
    end

    assert_redirected_to reports_path
    assert_equal I18n.t("reports.destroy.success"), flash[:success]
  end

  test "#update replaces journals and aggregated data in one save" do
    report = create(:report)
    existing_journal = create(:journal)
    removed_journal = create(:journal)
    added_journal = create(:journal)

    report.journals << [existing_journal, removed_journal]

    retained_datum = create(:aggregated_datum, report: report, additional_text: "Keep me", value: 10)
    removed_datum = create(:aggregated_datum, report: report, additional_text: "Remove me", value: 5)

    patch report_path(report), params: {
      journal_ids: [existing_journal.id, added_journal.id],
      retained_aggregated_datum_ids: [retained_datum.id],
      new_aggregated_data: {
        "0" => { value: "12.50", additional_text: "New entry" }
      }
    }

    assert_response :redirect
    assert_redirected_to report_path(report)
    assert_equal I18n.t("reports.update.success"), flash[:success]

    report.reload

    assert_equal [existing_journal.id, added_journal.id].sort, report.journal_ids.sort
    assert_includes report.aggregated_data.ids, retained_datum.id
    assert_not_includes report.aggregated_data.ids, removed_datum.id

    created = report.aggregated_data.find_by(additional_text: "New entry")

    assert_not_nil created
    assert_equal "AggregatedNumericalDatum", created.type
    assert_equal 12.5, created.value.to_f
  end

  test "#update rejects malformed aggregated data" do
    report = create(:report)
    report_journal = create(:journal)
    report.journals << report_journal
    retained_datum = create(:aggregated_datum, report: report, additional_text: "Retain", value: 3)

    patch report_path(report), params: {
      journal_ids: [report_journal.id],
      retained_aggregated_datum_ids: [retained_datum.id],
      new_aggregated_data: {
        "0" => { value: "", additional_text: "Missing value" }
      }
    }

    assert_response :redirect
    assert_redirected_to edit_report_path(report)
    assert_equal I18n.t("reports.update.invalid"), flash[:error]

    report.reload
    assert_equal [report_journal.id], report.journal_ids
    assert_equal [retained_datum.id], report.aggregated_data.ids
  end
end
