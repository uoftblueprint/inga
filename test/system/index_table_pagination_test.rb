require "application_system_test_case"

class IndexTablePaginationTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin)
    12.times { |i| create(:region, name: "Region #{format('%02d', i + 1)}") }

    visit login_path
    fill_in "Username", with: @admin.username
    fill_in "Password", with: "password"
    click_on "Login"
    assert_text "Projects"
  end

  test "paginates rows and shows controls when records exceed per page" do
    visit regions_path

    assert_selector ".join button", text: "1"

    visible_rows = all("[data-index-table-component-target='row']", visible: true)
    assert_equal 10, visible_rows.count

    assert_selector ".join button", text: "«"
    assert_selector ".join button", text: "»"
    assert_selector ".join button", text: "2"
  end

  test "hides pagination when records fit in one page" do
    Region.destroy_all
    5.times { |i| create(:region, name: "Small Region #{i + 1}") }

    visit regions_path

    visible_rows = all("[data-index-table-component-target='row']", visible: true)
    assert_equal 5, visible_rows.count
    assert_no_selector ".join button", text: "2"
  end
end
