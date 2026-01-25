require "test_helper"

class SubprojectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @project = create(:project)
    @region = create(:region)
    @subproject = create(:subproject, project: @project, region: @region)
  end

  [
    { route: "index", method: :get, url_helper: :project_subprojects_url },
    { route: "new", method: :get, url_helper: :new_project_subproject_url },
    { route: "create", method: :post, url_helper: :project_subprojects_url },
    { route: "show", method: :get, url_helper: :project_subproject_url, needs_subproject: true },
    { route: "edit", method: :get, url_helper: :edit_project_subproject_url, needs_subproject: true },
    { route: "update", method: :patch, url_helper: :project_subproject_url, needs_subproject: true },
    { route: "destroy", method: :delete, url_helper: :project_subproject_url, needs_subproject: true }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      args = [@project]
      args << create(:subproject, project: @project, region: @region) if hash[:needs_subproject]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user

      args = [@project]
      args << create(:subproject, project: @project, region: @region) if hash[:needs_subproject]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  [
    { route: "index", method: :get, url_helper: :project_subprojects_url },
    { route: "new", method: :get, url_helper: :new_project_subproject_url },
    { route: "show", method: :get, url_helper: :project_subproject_url, needs_subproject: true },
    { route: "edit", method: :get, url_helper: :edit_project_subproject_url, needs_subproject: true }
  ].each do |hash|
    test "##{hash[:route]} renders successfully when a user is an admin" do
      args = [@project]
      args << create(:subproject, project: @project, region: @region) if hash[:needs_subproject]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :success
    end
  end

  test "#index successfully renders a created subproject" do
    other = create(:subproject, project: @project, region: @region, name: "Other Subproject")

    get project_subprojects_url(@project)
    assert_response :success

    assert_select "div", text: @subproject.name
    assert_select "div", text: other.name
  end

  test "#show successfully renders subproject details" do
    subproject = create(
      :subproject,
      project: @project,
      region: @region,
      name: "Test Subproject",
      description: "Show description",
      address: "321 Show St"
    )

    get project_subproject_url(@project, subproject)
    assert_response :success

    assert_match subproject.name, response.body
    assert_match subproject.description, response.body
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

  test "#create enforces uniqueness of subproject name" do
    existing = create(:subproject, project: @project, region: @region, name: "Unique Subproject")

    assert_no_difference("Subproject.count") do
      post project_subprojects_url(@project), params: {
        subproject: {
          name: existing.name,
          description: "Another description",
          address: "Another address",
          region_id: @region.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "#update successfully updates a subproject" do
    updated_description = "Updated Description"

    patch project_subproject_path(@project, @subproject), params: {
      subproject: {
        description: updated_description
      }
    }

    assert_redirected_to project_subproject_path(@project, @subproject)

    assert_equal @subproject.reload.description, updated_description
  end

  test "#update does not update a subproject with invalid params" do
    original_name = @subproject.name

    patch project_subproject_path(@project, @subproject), params: {
      subproject: { name: "" }
    }

    assert_response :unprocessable_entity
    assert_equal original_name, @subproject.reload.name
  end

  test "#update enforces uniqueness of subproject name" do
    existing_subproject = create(:subproject, project: @project, region: @region)
    original_name = @subproject.name

    patch project_subproject_path(@project, @subproject), params: {
      subproject: { name: existing_subproject.name }
    }

    assert_response :unprocessable_entity
    assert_equal @subproject.reload.name, original_name
  end

  test "#destroy successfully deletes a subproject when user is an admin" do
    assert_difference("Subproject.count", -1) do
      delete project_subproject_url(@project, @subproject)
    end

    assert_redirected_to project_subprojects_url(@project)
  end
end
