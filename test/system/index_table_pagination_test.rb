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

    assert_selector "[data-index-table-component-target='pagination'] button", text: "1"

    visible_rows = all("[data-index-table-component-target='row']", visible: true)
    assert_equal 10, visible_rows.count

    assert_selector "[data-index-table-component-target='pagination'] button", text: "«"
    assert_selector "[data-index-table-component-target='pagination'] button", text: "»"
    assert_selector "[data-index-table-component-target='pagination'] button", text: "2"
  end

  test "clicking page shows correct rows and marks page as active" do
    visit regions_path
    assert_selector "[data-index-table-component-target='pagination'] button", text: "2"

    within "[data-index-table-component-target='pagination']" do
      click_button "2"
    end

    assert_selector "[data-index-table-component-target='pagination'] button.btn-active", text: "2"

    visible_rows = all("[data-index-table-component-target='row']", visible: true)
    assert_equal 2, visible_rows.count

    assert_no_selector "[data-index-table-component-target='pagination'] button.btn-active", text: "1"
  end

  test "filtering resets to page 1 and updates pagination controls" do
    visit regions_path
    assert_selector "[data-index-table-component-target='pagination'] button", text: "2"

    within "[data-index-table-component-target='pagination']" do
      click_button "2"
    end

    find("input[type='search']").fill_in with: "Region 01"

    assert_no_selector "[data-index-table-component-target='pagination'] button", text: "2"

    visible_rows = all("[data-index-table-component-target='row']", visible: true)
    assert_equal 1, visible_rows.count
  end

  test "hides pagination when records fit in one page" do
    visit regions_path

    find("input[type='search']").fill_in with: "Region 01"

    assert_no_selector "[data-index-table-component-target='pagination'] button", text: "2"

    visible_rows = all("[data-index-table-component-target='row']", visible: true)
    assert_equal 1, visible_rows.count
  end
end
