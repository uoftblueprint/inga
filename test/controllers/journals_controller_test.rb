require "test_helper"

class JournalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_logged_in_admin_user
    @project = create(:project)
    @region = create(:region)
    @subproject = create(:subproject, project: @project, region: @region)
    @journal = create(:journal, subproject: @subproject, user: @user, markdown_content: "Show me")
  end

  [
    { route: "new", method: :get, url_helper: :new_project_subproject_journal_url },
    { route: "create", method: :post, url_helper: :project_subproject_journals_url },
    { route: "show", method: :get, url_helper: :project_subproject_journal_url, needs_journal: true }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      args = [@project, @subproject]
      args << create(:journal, subproject: @subproject, user: @user) if hash[:needs_journal]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user

      args = [@project, @subproject]
      args << create(:journal, subproject: @subproject, user: @user) if hash[:needs_journal]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  [
    { route: "new", method: :get, url_helper: :new_project_subproject_journal_url }
  ].each do |hash|
    test "##{hash[:route]} renders successfully when a user is an admin" do
      args = [@project, @subproject]
      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :success
    end
  end

  test "#show renders a journal's content" do
    get project_subproject_journal_url(@project, @subproject, @journal)
    assert_response :success

    assert_match @journal.markdown_content.to_s, response.body
  end

  test "#create successfully creates a journal with valid params" do
    assert_difference("Journal.count", 1) do
      post project_subproject_journals_url(@project, @subproject), params: {
        journal: { markdown_content: "Journal body content" }
      }
    end
  end
end
