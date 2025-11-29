require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
  end

  test "create makes project with valid params" do
    assert_difference("Project.count", 1) do
      post projects_path, params: { project: { name: "Test Project", description: "Test description" } }
    end

    assert_redirected_to project_path(Project.last)
    assert_equal true, Project.last.active
  end

  test "create does not create project without name" do
    assert_no_difference("Project.count") do
      post projects_path, params: { project: { name: "", description: "Test description" } }
    end

    assert_response :unprocessable_entity
  end

  test "create does not create project without description" do
    assert_no_difference("Project.count") do
      post projects_path, params: { project: { name: "Test Project", description: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "create sets project as active by default" do
    post projects_path, params: { project: { name: "Test Project", description: "Test description" } }

    project = Project.last
    assert project.active
  end
end
