require "test_helper"

class ProjectsModalControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Create or reuse a user
    @user = begin
      create(:user)
    rescue StandardError
      User.create!(username: "tester", password: "password")
    end

    # Log in the user; ensure session is set
    post login_url, params: { username: @user.username, password: "password" }, as: :form
    follow_redirect! if response.redirect?

    # Give the user an admin role for authorization
    @user.user_roles.create!(role: "admin") unless @user.user_roles.exists?(role: "admin")
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
    assert_includes @response.body, 'action="replace"'
    assert_includes @response.body, 'target="projects-list"'
    assert_includes @response.body, 'create_project_modal'
  end
end
