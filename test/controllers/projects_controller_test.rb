require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @project = create(:project)
  end

  [
    { route: "show", method: :get, url_helper: :project_url }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      public_send(hash[:method], public_send(hash[:url_helper], @project))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user

      public_send(hash[:method], public_send(hash[:url_helper], @project))
      assert_response :redirect
      assert_redirected_to root_path
    end

    test "##{hash[:route]} renders successfully when a user is an admin" do
      public_send(hash[:method], public_send(hash[:url_helper], @project))
      assert_response :success
    end
  end

  test "#show renders the project data correctly" do
    project = create(:project,
                     name: "Test project",
                     description: "Project description",
                     active: true)

    get project_path(project)
    assert_response :success

    assert_match project.name, response.body
    assert_match project.description, response.body
  end
end
