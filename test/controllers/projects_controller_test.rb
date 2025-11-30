require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
  end

  test "#show renders successfully when user is authorised" do
    project = create(:project,
                     name: "Test project",
                     description: "Project description",
                     active: true)

    get project_path(project)
    assert_response :success

    assert_match project.name, response.body
    assert_match project.description, response.body
    assert_match "Yes", response.body
  end

  test "#show redirects to login route when user is not logged in" do
    log_out_user

    project = create(:project)
    get project_path(project)
    assert_response :redirect
    assert_redirected_to login_path
  end
end
