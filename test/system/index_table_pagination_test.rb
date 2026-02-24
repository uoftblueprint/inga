require "application_system_test_case"

class IndexTablePaginationTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin)
    12.times { |i| create(:region, name: "Region #{format('%02d', i + 1)}") }
    sign_in_as(@admin)
  end

  test "paginates rows and shows prev/next controls" do
    visit regions_path

    assert_selector "[data-index-table-component-target='pageInfo']", text: "1 of 2"

    visible_rows = all("[data-index-table-component-target='row']", visible: true)
    assert_equal 10, visible_rows.count
  end

  test "clicking next shows remaining rows" do
    visit regions_path
    assert_selector "[data-index-table-component-target='pageInfo']", text: "1 of 2"

    within "[data-index-table-component-target='pagination']" do
      click_button ">"
    end

    assert_selector "[data-index-table-component-target='pageInfo']", text: "2 of 2"

    visible_rows = all("[data-index-table-component-target='row']", visible: true)
    assert_equal 2, visible_rows.count
  end

  test "filtering resets to first page" do
    visit regions_path
    assert_selector "[data-index-table-component-target='pageInfo']", text: "1 of 2"

    within "[data-index-table-component-target='pagination']" do
      click_button ">"
    end
    assert_selector "[data-index-table-component-target='pageInfo']", text: "2 of 2"

    find("input[type='search']").fill_in with: "Region 01"

    assert_no_selector "[data-index-table-component-target='pagination']", visible: true

    visible_rows = all("[data-index-table-component-target='row']", visible: true)
    assert_equal 1, visible_rows.count
  end

  test "hides pagination when results fit on one page" do
    visit regions_path

    find("input[type='search']").fill_in with: "Region 01"

    assert_no_selector "[data-index-table-component-target='pagination']", visible: true

    visible_rows = all("[data-index-table-component-target='row']", visible: true)
    assert_equal 1, visible_rows.count
  end
end
