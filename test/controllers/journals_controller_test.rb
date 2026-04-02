require "test_helper"

class JournalsControllerTest < ActionDispatch::IntegrationTest
  test "#new redirects to login when unauthenticated" do
    get new_journal_url

    assert_response :redirect
    assert_redirected_to login_path
  end

  test "#new redirects admins to projects" do
    create_logged_in_user_with_roles(:admin)

    get new_journal_url

    assert_response :redirect
    assert_redirected_to projects_path
  end

  test "#new renders for reporters" do
    create_logged_in_user_with_roles(:reporter)

    get new_journal_url

    assert_response :success
  end
end
