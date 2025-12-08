require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @project = create(:project)
  end

  [
    { route: "show", method: :get, url_helper: :project_url },
    { route: "new", method: :get, url_helper: :new_project_url },
    { route: "create", method: :post, url_helper: :projects_url },
    { route: "index", method: :get, url_helper: :projects_url }
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
  end

  [
    { route: "show", method: :get, url_helper: :project_url },
    { route: "new", method: :get, url_helper: :new_project_url }
  ].each do |hash|
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

  test "create makes project with valid params" do
    project_name = "Test Project"

    assert_difference("Project.count", 1) do
      post projects_path, params: { project: { name: project_name, description: "Test description", active: true } }
    end

    new_project = Project.find_by!(name: project_name)
    assert_equal "Test description", new_project.description
    assert new_project.active
  end

  test "#create enforces uniqueness of project name" do
    project_name = "Unique Project"
    create(:project, name: project_name)

    assert_no_difference("Project.count") do
      post projects_path, params: { project: { name: project_name, description: "Another description", active: true } }
    end
    assert_response :unprocessable_entity
  end

  test "#index shows all projects with no filter" do
    project1 = create(:project, name: "First Project")
    project2 = create(:project, name: "Second Project")

    get projects_path
    assert_response :success

    assert_match project1.name, response.body
    assert_match project2.name, response.body
  end

  test "#index renders the correct projects when filtered" do
    project1 = create(:project, name: "First Project")
    project2 = create(:project, name: "Second Project")

    get projects_path, params: { name: "First" }
    assert_match project1.name, response.body
    assert_no_match project2.name, response.body

    get projects_path, params: { name: "oject" }
    assert_match project1.name, response.body
    assert_match project2.name, response.body
  end
end
