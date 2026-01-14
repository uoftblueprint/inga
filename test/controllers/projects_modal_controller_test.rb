require "test_helper"

class ProjectsControllerTurboStreamTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_logged_in_admin_user
  end

  test "create responds with turbo stream updating projects list and closing modal" do
    post projects_path, params: {
      project: {
        name: "TS Project",
        description: "from controller test",
        active: true
      }
    }, as: :turbo_stream

    assert_response :success

    # Ensure response is a Turbo Stream
    assert_equal "text/vnd.turbo-stream.html", @response.media_type

    # Check that the projects list is updated and modal is targeted
    assert_includes @response.body, "action=\"replace\""
    assert_includes @response.body, "target=\"projects-list\""
    assert_includes @response.body, "create_project_modal"
  end
end
