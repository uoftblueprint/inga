require "test_helper"

class RegionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @region = create(:region, name: "region1")
    create_logged_in_admin_user
  end

  test "#index redirects to login path when user is not logged in" do
    log_out_user
    get regions_path
    assert_redirected_to login_path
  end

  test "#index successfully renders when user is an admin" do
    get regions_path
    assert_response :success
  end

  test "#index redirects to root path when user is not authorized" do
    create_logged_in_user
    get regions_path
    assert_redirected_to root_path
  end

  test "#index displays all regions" do
    create(:region, name: "region2")
    get regions_path
    assert_response :success
    assert_select "td", text: "region1"
    assert_select "td", text: "region2"
  end
end
