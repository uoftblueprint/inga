require "test_helper"

class LogEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_logged_in_admin_user
    @project = create(:project)
    @region = create(:region)
    @subproject = create(:subproject, project: @project, region: @region)
    @log_entry = create(:log_entry, subproject: @subproject, user: @user)
  end

  [
    { route: "new", method: :get, url_helper: :new_project_subproject_log_entry_url },
    { route: "create", method: :post, url_helper: :project_subproject_log_entries_url },
    { route: "show", method: :get, url_helper: :project_subproject_log_entry_url, needs_log_entry: true },
    { route: "edit", method: :get, url_helper: :edit_project_subproject_log_entry_url, needs_log_entry: true },
    { route: "update", method: :patch, url_helper: :project_subproject_log_entry_url, needs_log_entry: true },
    { route: "destroy", method: :delete, url_helper: :project_subproject_log_entry_url, needs_log_entry: true }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      args = [@project, @subproject]
      args << create(:log_entry, subproject: @subproject, user: @user) if hash[:needs_log_entry]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user

      args = [@project, @subproject]
      args << create(:log_entry, subproject: @subproject, user: @user) if hash[:needs_log_entry]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  [
    { route: "new", method: :get, url_helper: :new_project_subproject_log_entry_url },
    { route: "edit", method: :get, url_helper: :edit_project_subproject_log_entry_url, needs_log_entry: true }
  ].each do |hash|
    test "##{hash[:route]} renders turbo_stream successfully when a user is an admin" do
      args = [@project, @subproject]
      args << @log_entry if hash[:needs_log_entry]

      public_send(hash[:method], public_send(hash[:url_helper], *args), as: :turbo_stream)
      assert_response :success
      assert_equal "text/vnd.turbo-stream.html", @response.media_type
    end
  end

  test "#show renders a log_entry's content" do
    get project_subproject_log_entry_url(@project, @subproject, @log_entry), as: :turbo_stream
    assert_response :success

    assert_match @log_entry.metadata["content"].to_s, response.body
  end

  test "#create successfully creates a log_entry with valid params" do
    assert_difference("LogEntry.count", 1) do
      post project_subproject_log_entries_url(@project, @subproject), params: {
        log_entry: { metadata: { content: "Test content" } }
      }
    end
  end

  test "#update successfully updates a log_entry" do
    updated_content = "Updated Content"

    patch project_subproject_log_entry_path(@project, @subproject, @log_entry), params: {
      log_entry: { metadata: { content: updated_content } }
    }

    assert_redirected_to project_subproject_path(@project, @subproject)
    assert_equal updated_content, @log_entry.reload.metadata["content"],
                 "Expected log_entry metadata 'content' to be updated"
  end

  test "#destroy successfully deletes a log_entry when a user is an admin" do
    assert_difference("LogEntry.count", -1) do
      delete project_subproject_log_entry_url(@project, @subproject, @log_entry)
    end

    assert_redirected_to project_subproject_url(@project, @subproject)
  end
end
