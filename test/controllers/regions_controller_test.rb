require "test_helper"

class RegionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @region = create(:region, name: "region1")
  end

  [
    { route: "index", method: :get, url_helper: :regions_url  },
    { route: "new", method: :get, url_helper: :new_region_url },
    { route: "create", method: :post, url_helper: :regions_url },
    { route: "edit", method: :get, url_helper: :edit_region_url, needs_region: true },
    { route: "update", method: :patch, url_helper: :region_url, needs_region: true }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      args = create(:region) if hash[:needs_region]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user

      args = create(:region) if hash[:needs_region]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  [
    { route: "index", method: :get, url_helper: :regions_url },
    { route: "new", method: :get, url_helper: :new_region_url },
    { route: "edit", method: :get, url_helper: :edit_region_url, needs_region: true }
  ].each do |hash|
    test "##{hash[:route]} renders successfully when a user is an admin" do
      args = create(:region) if hash[:needs_region]

      public_send(hash[:method], public_send(hash[:url_helper], *args))
      assert_response :success
    end
  end

  test "#index displays all regions" do
    region2 = create(:region, name: "region2")

    get regions_path

    assert_response :success
    assert_select "td", text: @region.name
    assert_select "td", text: region2.name
  end

  test "#create successfully creates a region with valid params" do
    region2 = build(:region, name: "region2")

    region_params = {
      name: region2.name,
      latitude: region2.latitude,
      longitude: region2.longitude
    }

    assert_difference("Region.count", 1) do
      post regions_path, params: {
        region: region_params
      }
    end

    new_region = Region.find_by!(name: region2.name)
    assert_equal region2.name, new_region.name
  end

  test "#create creates only one region with a given name" do
    region2 = build(:region, name: "region2")

    params = { region: {
      name: region2.name,
      latitude: region2.latitude,
      longitude: region2.longitude
    } }

    assert_difference("Region.count", 1) do
      post regions_path, params: params
      post regions_path, params: params
    end
  end

  test "#create does not create a region with invalid params" do
    assert_no_difference("Region.count") do
      post regions_path, params: { region: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "#update successfully updates a region" do
    updated_name = "updated-region"

    patch region_path(@region), params: {
      region: {
        name: updated_name
      }
    }

    assert_redirected_to regions_path
    assert_equal updated_name, @region.reload.name
  end

  test "#update fails when a region name is already taken" do
    existing_region = create(:region, name: "taken-name")
    original_name = @region.name

    patch region_path(@region), params: {
      region: { name: existing_region.name }
    }

    assert_response :unprocessable_entity
    assert_equal original_name, @region.reload.name
  end
end
