require "test_helper"

class SubprojectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @project = create(:project)
    @region = create(:region)
  end

  [
    { route: "new", method: :get, url_helper: :new_project_subproject_url },
    { route: "create", method: :post, url_helper: :project_subprojects_url },
    { route: "index", method: :get, url_helper: :project_subprojects_url },
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
    { route: "new", method: :get, url_helper: :new_project_subproject_url },
    { route: "index", method: :get, url_helper: :project_subprojects_url },
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
    subproject = create(:subproject, project: @project, region: @region)

    get project_subprojects_url(@project)
    assert_response :success

    assert_select "table tr", count: 2 do |rows|
      assert_select rows[1], "td" do |cells|
        assert_equal subproject.name.to_s, cells[0].text.strip
        assert_equal subproject.description.to_s, cells[1].text.strip
        assert_equal subproject.address.to_s, cells[2].text.strip
        assert_equal subproject.region.name.to_s, cells[3].text.strip
      end
    end
  end

  test "#index filters out a non-matching subproject" do
    matching_subproject = create(:subproject, project: @project, region: @region)
    create(:subproject, project: @project, region: @region)

    get project_subprojects_url(@project, name: matching_subproject.name)
    assert_response :success

    assert_select "table tr", count: 2 do |rows|
      assert_select rows[1], "td" do |cells|
        assert_equal matching_subproject.name.to_s, cells[0].text.strip
        assert_equal matching_subproject.description.to_s, cells[1].text.strip
        assert_equal matching_subproject.address.to_s, cells[2].text.strip
        assert_equal matching_subproject.region.name.to_s, cells[3].text.strip
      end
    end
  end

  test "#update sucessfully updates a subproject" do
    subproject = create(:subproject, project: @project, region: @region)
    updated_description = "Updated Description"

    patch project_subproject_path(@project, subproject), params: {
      subproject: {
        description: updated_description
      }
    }

    assert_redirected_to project_subproject_path(@project, subproject)

    assert_equal subproject.reload.description, updated_description
  end

  test "#update fails when a subproject name is already taken" do
    existing_subproject = create(:subproject, project: @project, region: @region)
    subproject = create(:subproject, project: @project, region: @region)

    original_name = subproject.name

    patch project_subproject_path(@project, subproject), params: {
      subproject: { name: existing_subproject.name }
    }

    assert_response :unprocessable_entity
    assert_equal subproject.reload.name, original_name
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

    assert_redirected_to project_path(@project)
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
      assert_redirected_to project_path(@project)

      post project_subprojects_url(@project), params: params
      assert_response :unprocessable_entity
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
  test "#destroy successfully deletes a subproject when user is an admin" do
    subproject = create(:subproject, project: @project, region: @region)

    assert_difference("Subproject.count", -1) do
      delete project_subproject_url(@project, subproject)
    end

    assert_redirected_to project_subprojects_url(@project)
  end

  test "#destroy does not delete a subproject if subproject does not belong to project" do
    other_project = create(:project)
    subproject = create(:subproject, project: other_project, region: @region)

    assert_no_difference("Subproject.count") do
      delete project_subproject_url(@project, subproject)
    end

    assert_response :not_found
  end
end
