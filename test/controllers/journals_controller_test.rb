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
    { route: "index", method: :get, url_helper: :project_subproject_journals_url },
    { route: "new", method: :get, url_helper: :new_project_subproject_journal_url },
    { route: "create", method: :post, url_helper: :project_subproject_journals_url },
    { route: "show", method: :get, url_helper: :project_subproject_journal_url, needs_journal: true },
    { route: "edit", method: :get, url_helper: :edit_project_subproject_journal_url, needs_journal: true },
    { route: "update", method: :patch, url_helper: :project_subproject_journal_url, needs_journal: true },
    { route: "destroy", method: :delete, url_helper: :project_subproject_journal_url, needs_journal: true }
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
    { route: "index", method: :get, url_helper: :project_subproject_journals_url },
    { route: "new", method: :get, url_helper: :new_project_subproject_journal_url },
    { route: "edit", method: :get, url_helper: :edit_project_subproject_journal_url, needs_journal: true }
  ].each do |hash|
    test "##{hash[:route]} renders successfully when a user is an admin" do
      args = [@project, @subproject]
      args << @journal if hash[:needs_journal]
      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :success
    end
  end

  test "#show renders a journal's content" do
    get project_subproject_journal_url(@project, @subproject, @journal)
    assert_response :success

    assert_match @journal.markdown_content.to_s, response.body
  end

  test "#index renders all journals" do
    other = create(:journal, subproject: @subproject, user: @user, markdown_content: "Other Journal content")

    get project_subproject_journals_url(@project, @subproject)
    assert_response :success

    assert_select "td", text: @journal.markdown_content.to_plain_text
    assert_select "td", text: other.markdown_content.to_plain_text
  end

  test "#create successfully creates a journal with valid params" do
    assert_difference("Journal.count", 1) do
      post project_subproject_journals_url(@project, @subproject), params: {
        journal: { markdown_content: "Journal body content" }
      }
    end
  end

  test "#update successfully updates a journal" do
    updated_content = "Updated Content"

    patch project_subproject_journal_path(@project, @subproject, @journal), params: {
      journal: { markdown_content: updated_content }
    }

    assert_redirected_to project_subproject_journal_path(@project, @subproject, @journal)
    assert_equal updated_content, @journal.reload.markdown_content.to_plain_text
  end

  test "#destroy successfully deletes a journal when a user is an admin" do
    assert_difference("Journal.count", -1) do
      delete project_subproject_journal_url(@project, @subproject, @journal)
    end

    assert_redirected_to project_subproject_journals_url(@project, @subproject)
  end
end
