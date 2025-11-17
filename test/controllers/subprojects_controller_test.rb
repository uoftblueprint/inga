require "test_helper"

class SubprojectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    post login_url, params: { username: @user.username, password: @user.password }
    @project = create(:project)
    @region = create(:region)
  end

  test "should get new" do
    get new_project_subproject_url(@project)
    assert_response :success
    assert_select "form"
  end

  test "should create subproject with valid params" do
    assert_difference("Subproject.count", 1) do
      post project_subprojects_url(@project), params: {
        subproject: {
          name: "New Subproject",
          description: "A description",
          address: "123 Main St",
          region_id: @region.id
        }
      }
    end

    new_subproject = Subproject.last
    assert_equal @project.id, new_subproject.project_id
    assert_equal @region.id, new_subproject.region_id

    assert_redirected_to project_subproject_path(@project, new_subproject)
  end

  test "should not create subproject with invalid params" do
    assert_no_difference("Subproject.count") do
      post project_subprojects_url(@project), params: {
        subproject: {
          name: "Test name",
          description: "Test description",
          address: "123 Main St",
          region_id: nil # Invalid param
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "form"
  end

  test "should not create subproject with non-existent region" do
    assert_no_difference("Subproject.count") do
      post project_subprojects_url(@project), params: {
        subproject: {
          name: "Test name",
          description: "Test description",
          address: "123 Main St",
          region_id: 999_999 # Non-existent region
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "form"
  end
end
