require "test_helper"

class LogEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    post login_url, params: { username: @user.username, password: @user.password }

    @region = create(:region)
    @project = create(:project, log_schema: {
                        "temperature" => "numerical",
                        "verified" => "boolean",
                        "notes" => "text"
                      })
    @subproject = create(:subproject, project: @project, region: @region)
  end

  test "should create log_entry with valid params" do
    assert_difference("LogEntry.count") do
      post project_subproject_log_entries_url(@project, @subproject), params: {
        log_entry: {
          datetime: Time.current,
          metadata: {
            "temperature" => 25.5,
            "verified" => true,
            "notes" => "Test entry"
          }
        }
      }, as: :json
    end

    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal @subproject.id, json_response["subproject_id"]
    assert_equal @user.id, json_response["user_id"]
    assert_equal 25.5, json_response["metadata"]["temperature"]
  end

  test "should not create log_entry without subproject" do
    skip "Subproject is required by the route structure"
  end

  test "should not create log_entry without datetime" do
    assert_no_difference("LogEntry.count") do
      post project_subproject_log_entries_url(@project, @subproject), params: {
        log_entry: {
          metadata: {}
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"].join, "Datetime"
  end

  test "should not create log_entry with invalid metadata types" do
    assert_no_difference("LogEntry.count") do
      post project_subproject_log_entries_url(@project, @subproject), params: {
        log_entry: {
          datetime: Time.current,
          metadata: {
            "temperature" => "hot",
            "verified" => "yes"
          }
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"].join, "temperature must be a number"
  end

  test "should not create log_entry with unexpected metadata fields" do
    assert_no_difference("LogEntry.count") do
      post project_subproject_log_entries_url(@project, @subproject), params: {
        log_entry: {
          datetime: Time.current,
          metadata: {
            "unexpected_field" => "value"
          }
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"].join, "unexpected fields"
  end

  test "should create log_entry with partial metadata" do
    assert_difference("LogEntry.count") do
      post project_subproject_log_entries_url(@project, @subproject), params: {
        log_entry: {
          datetime: Time.current,
          metadata: {
            "temperature" => 20.0
          }
        }
      }, as: :json
    end

    assert_response :created
  end

  test "should create log_entry with empty metadata" do
    assert_difference("LogEntry.count") do
      post project_subproject_log_entries_url(@project, @subproject), params: {
        log_entry: {
          datetime: Time.current,
          metadata: {}
        }
      }, as: :json
    end

    assert_response :created
  end

  test "#create redirects to login route when a user is not authenticated" do
    delete logout_url

    post project_subproject_log_entries_url(@project, @subproject), params: {
      log_entry: {
        datetime: Time.current,
        metadata: {}
      }
    }, as: :json

    assert_response :redirect
    assert_redirected_to login_path
  end
end
