require "application_system_test_case"

class IndexTableSortingTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin)
    sign_in_as(@admin)
  end

  test "defaults to created_at descending when column exists" do
    project = create(:project)
    region = create(:region)
    create(:subproject, project: project, region: region, name: "Canada", created_at: 2.days.ago)
    create(:subproject, project: project, region: region, name: "Germany", created_at: 1.hour.ago)

    visit project_path(id: project.id)

    assert_selector "[data-sort-indicator='3']", text: "▼"
  end

  test "falls back to first sortable column descending when no created_at" do
    create(:region, name: "Canada")
    create(:region, name: "New Zealand")
    create(:region, name: "Germany")

    visit regions_path
    assert_selector "[data-sort-indicator='0']", text: "▼"

    names = all("[data-index-table-component-target='row']", visible: true).map do |r|
      r.find("[data-col-index='0']").text
    end
    assert_equal ["New Zealand", "Germany", "Canada"], names
  end

  test "clicking the sorted column toggles direction" do
    create(:region, name: "Canada")
    create(:region, name: "New Zealand")
    create(:region, name: "Germany")

    visit regions_path
    assert_selector "[data-sort-indicator='0']", text: "▼"
    click_button "Name"

    names = all("[data-index-table-component-target='row']", visible: true).map do |r|
      r.find("[data-col-index='0']").text
    end
    assert_equal ["Canada", "Germany", "New Zealand"], names
    assert_equal "▲", find("[data-sort-indicator='0']").text
  end

  test "actions column is not sortable" do
    visit regions_path
    assert_selector "[data-controller='index-table-component']"

    assert_no_selector "button", text: "Actions"
  end
end
