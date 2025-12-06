require "test_helper"

class RegionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @region = create(:region, name: "region1")
  end

  [
    { route: "index", method: :get, url_helper: :regions_url  },
    { route: "new", method: :get, url_helper: :new_region_url },
    { route: "create", method: :post, url_helper: :regions_url }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      public_send(hash[:method], public_send(hash[:url_helper]))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user

      public_send(hash[:method], public_send(hash[:url_helper]))
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  [
    { route: "index", method: :get, url_helper: :regions_url },
    { route: "new", method: :get, url_helper: :new_region_url }
  ].each do |hash|
    test "##{hash[:route]} renders successfully when a user is an admin" do
      public_send(hash[:method], public_send(hash[:url_helper]))
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
end
