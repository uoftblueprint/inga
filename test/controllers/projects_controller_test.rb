require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
  end

  [
    { route: "new", method: :get, url_helper: :new_project_url },
    { route: "create", method: :post, url_helper: :projects_url }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      public_send(hash[:method], public_send(hash[:url_helper]))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user

      public_send(hash[:method], public_send(hash[:url_helper]))
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  test "#new renders successfully when a user is an admin" do
    get new_project_url
    assert_response :success
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

  test "create makes inactive project when active is false" do
    project_name = "Inactive Project"

    assert_difference("Project.count", 1) do
      post projects_path, params: { project: { name: project_name, description: "Test description", active: false } }
    end

    new_project = Project.find_by!(name: project_name)
    assert_equal "Test description", new_project.description
    assert_not new_project.active
  end

  test "create does not create project without name" do
    assert_no_difference("Project.count") do
      post projects_path, params: { project: { name: "", description: "Test description" } }
    end

    assert_response :unprocessable_entity
  end
end
