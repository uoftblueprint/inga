require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @project = create(:project)
  end

  [
    { route: "index", method: :get, url_helper: :projects_url },
    { route: "show", method: :get, url_helper: :project_url, needs_project: true },
    { route: "new", method: :get, url_helper: :new_project_url },
    { route: "create", method: :post, url_helper: :projects_url },
    { route: "destroy", method: :delete, url_helper: :project_url, needs_project: true },
    { route: "edit", method: :get, url_helper: :edit_project_url, needs_project: true },
    { route: "update", method: :patch, url_helper: :project_url, needs_project: true }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      args = create(:project) if hash[:needs_project]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user

      args = create(:project) if hash[:needs_project]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  [
    { route: "index", method: :get, url_helper: :projects_url },
    { route: "new", method: :get, url_helper: :new_project_url },
    { route: "show", method: :get, url_helper: :project_url, needs_project: true },
    { route: "edit", method: :get, url_helper: :edit_project_url, needs_project: true }
  ].each do |hash|
    test "##{hash[:route]} renders successfully when a user is an admin" do
      args = create(:project) if hash[:needs_project]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :success
    end
  end

  test "#index shows all projects" do
    project1 = create(:project, name: "First Project")
    project2 = create(:project, name: "Second Project")

    get projects_path
    assert_response :success

    assert_select "h2", text: project1.name
    assert_select "h2", text: project2.name
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

  test "#create makes project with valid params" do
    project_name = "Test Project"

    assert_difference("Project.count", 1) do
      post projects_path, params: { project: { name: project_name, description: "Test description", active: true } }
    end

    new_project = Project.find_by!(name: project_name)
    assert_equal "Test description", new_project.description
    assert new_project.active
  end

  test "#create does not create a project with invalid params" do
    assert_no_difference("Project.count") do
      post projects_path, params: { project: { name: "", description: "", active: true } }
    end

    assert_response :unprocessable_entity
  end

  test "#create enforces uniqueness of project name" do
    existing = create(:project, name: "Unique Project")

    assert_no_difference("Project.count") do
      post projects_path, params: { project: { name: existing.name, description: "Another description", active: true } }
    end

    assert_response :unprocessable_entity
  end

  test "#update successfully updates a project" do
    updated_description = "Updated description"

    patch project_path(@project), params: {
      project: {
        description: updated_description
      }
    }

    assert_redirected_to project_path(@project)
    assert_equal @project.reload.description, updated_description
  end

  test "#update does not update a project with invalid params" do
    original_name = @project.name

    patch project_path(@project), params: { project: { name: "" } }

    assert_response :unprocessable_entity
    assert_equal original_name, @project.reload.name
  end

  test "#update enforces uniqueness of project name" do
    existing_project = create(:project)
    original_name = @project.name

    patch project_path(@project), params: {
      project: { name: existing_project.name }
    }

    assert_response :unprocessable_entity
    assert_equal original_name, @project.reload.name
  end

  test "#destroy successfully deletes a project when user is an admin" do
    assert_difference("Project.count", -1) do
      delete project_path(@project)
    end

    assert_redirected_to projects_path
  end
end
