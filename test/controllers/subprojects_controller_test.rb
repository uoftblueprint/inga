require "test_helper"

class SubprojectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @project = create(:project)
    @region = create(:region)
  end

  test "#new redirects to root route when a user is not logged in" do
    log_out_user
    get new_project_subproject_url(@project)
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "#new redirects to login route when a user is not authorized" do
    create_logged_in_user
    get new_project_subproject_url(@project)
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "#new renders successfully when a user is an admin" do
    get new_project_subproject_url(@project)
    assert_response :success
    assert_select "form"
  end

  test "#create successfully creates a subproject with valid params" do
    subproject_name = "Subproject name"

    assert_difference("Subproject.count", 1) do
      post project_subprojects_url(@project), params: {
        subproject: {
          name: subproject_name,
          description: "Subproject description",
          address: "Subproject address",
          region_id: @region.id
        }
      }
    end

    new_subproject = Subproject.find_by!(name: subproject_name)
    assert_equal @project.id, new_subproject.project_id
    assert_equal @region.id, new_subproject.region_id
  end

  test "#create creates only one subproject with a given name" do
    params = {
      subproject: {
        name: "Subproject name",
        description: "Subproject description",
        address: "Subproject address",
        region_id: @region.id
      }
    }

    assert_difference("Subproject.count", 1) do
      post project_subprojects_url(@project), params: params
      post project_subprojects_url(@project), params: params
    end
  end

  test "#create does not create a subproject with invalid params" do
    assert_no_difference("Subproject.count") do
      post project_subprojects_url(@project), params: {
        subproject: {
          name: "",
          description: "",
          address: "",
          region_id: @region.id
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
