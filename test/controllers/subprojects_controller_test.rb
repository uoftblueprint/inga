require "test_helper"

class SubprojectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_logged_in_admin_user
    @project = create(:project)
    @region = create(:region)
  end

  test "#new successfully returns a form" do
    get new_project_subproject_url(@project)
    assert_response :success
    assert_select "form"
  end
  
  test "#show action test where show renders subproject details" do 
    subproject = create(
      :subproject, 
      project: @project, 
      region: @region, 
      name: "Test Subprojcet",
      description: "Show description",
      address: "321 Show St"
    )

    get project_subproject_url(@project, subproject)
    assert_response :success

    assert_match subproject.name, response.body
    assert_match subproject.description, response.body
    assert_match subproject.address, response.body
    assert_match @project.name, response.body  
  end

  test "#create successfully creates a subproject with valid params" do
    subproject_name = "New Subproject"

    assert_difference("Subproject.count", 1) do
      post project_subprojects_url(@project), params: {
        subproject: {
          name: subproject_name,
          description: "A description",
          address: "123 Main St",
          region_id: @region.id
        }
      }
    end

    new_subproject = Subproject.find_by!(name: subproject_name)
    assert_equal @project.id, new_subproject.project_id
    assert_equal @region.id, new_subproject.region_id
  end

  test "#create does not create a subproject with invalid params" do
    assert_no_difference("Subproject.count") do
      post project_subprojects_url(@project), params: {
        subproject: {
          name: "",
          description: "",
          address: "",
          region_id: 1
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "#create does not create a subproject with a missing region" do
    assert_no_difference("Subproject.count") do
      post project_subprojects_url(@project), params: {
        subproject: {
          name: "Test name",
          description: "Test description",
          address: "123 Main St",
          region_id: nil
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "#create does not creates a subproject with a non-existent region" do
    assert_no_difference("Subproject.count") do
      post project_subprojects_url(@project), params: {
        subproject: {
          name: "Test name",
          description: "Test description",
          address: "123 Main St",
          region_id: 999_999
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
