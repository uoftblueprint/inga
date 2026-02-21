require "test_helper"

class LogEntryMetadataServiceTest < ActiveSupport::TestCase
  setup do
    @project = create(:project, log_schema: { "Trees Planted" => "numerical", "Flagged" => "boolean" })
    @subproject = create(:subproject, project: @project)

    @service = LogEntryMetadataService.new
  end

  test "categorizes metadata when all fields match schema" do
    create(:log_entry, subproject: @subproject, metadata: { "Trees Planted" => 43,
                                                            "Flagged" => true }, created_at: 3.days.ago)
    create(:log_entry, subproject: @subproject, metadata: { "Trees Planted" => 45,
                                                            "Flagged" => false }, created_at: 2.days.ago)

    result = @service.retrieve_categorized_metadata_for_range(Subproject.where(id: @subproject.id), 4.days.ago,
                                                              Time.current)

    assert_kind_of LogEntryMetadataService::CategorizedMetadata, result

    assert_equal([
                   { "Trees Planted" => 43 },
                   { "Trees Planted" => 45 }
                 ], result.numerical)
    assert_equal([
                   { "Flagged" => true },
                   { "Flagged" => false }
                 ], result.boolean)
  end

  test "categorizes metadata when some fields are missing" do
    create(:log_entry, subproject: @subproject, metadata: {
             "Flagged" => true
           }, created_at: 3.days.ago)
    create(:log_entry, subproject: @subproject, metadata: { "Trees Planted" => 45 },
                       created_at: 2.days.ago)

    result = @service.retrieve_categorized_metadata_for_range(Subproject.where(id: @subproject.id), 4.days.ago,
                                                              Time.current)

    assert_kind_of LogEntryMetadataService::CategorizedMetadata, result

    assert_equal([
                   { "Trees Planted" => 45 }
                 ], result.numerical)
    assert_equal([
                   { "Flagged" => true }
                 ], result.boolean)
  end

  test "ignores fields not specified in the schema" do
    create(:log_entry, subproject: @subproject, metadata: { "Trees Planted" => 43,
                                                            "Flagged" => true, "Other" => "ignored" },
                       created_at: 3.days.ago)
    create(:log_entry, subproject: @subproject, metadata: { "Trees Planted" => 45,
                                                            "Flagged" => false, "Other 2" => "also ignored" },
                       created_at: 2.days.ago)

    result = @service.retrieve_categorized_metadata_for_range(Subproject.where(id: @subproject.id), 4.days.ago,
                                                              Time.current)

    assert_kind_of LogEntryMetadataService::CategorizedMetadata, result

    assert_equal([
                   { "Trees Planted" => 43 },
                   { "Trees Planted" => 45 }
                 ], result.numerical)
    assert_equal([
                   { "Flagged" => true },
                   { "Flagged" => false }
                 ], result.boolean)
  end

  test "categorizes metadata correctly for multiple projects with conflicting schemas in the same date range" do
    other_project = create(:project, log_schema: { "Trees Planted" => "boolean" })
    other_subproject = create(:subproject, project: other_project)

    create(:log_entry, subproject: @subproject, metadata: { "Trees Planted" => 10,
                                                            "Flagged" => true }, created_at: 3.days.ago)
    create(:log_entry, subproject: other_subproject, metadata: { "Trees Planted" => true }, created_at: 2.days.ago)

    subprojects = Subproject.where(id: [@subproject.id, other_subproject.id])
    result = @service.retrieve_categorized_metadata_for_range(subprojects, 4.days.ago, Time.current)

    assert_kind_of LogEntryMetadataService::CategorizedMetadata, result

    assert_equal([
                   { "Trees Planted" => 10 }
                 ], result.numerical)
    assert_equal([
                   { "Flagged" => true },
                   { "Trees Planted" => true }
                 ], result.boolean)
  end

  test "excludes log entries outside of the specified date range" do
    create(:log_entry, subproject: @subproject, metadata: { "Trees Planted" => 43,
                                                            "Flagged" => true }, created_at: 5.days.ago)
    create(:log_entry, subproject: @subproject, metadata: { "Trees Planted" => 45,
                                                            "Flagged" => false }, created_at: 1.day.from_now)

    result = @service.retrieve_categorized_metadata_for_range(Subproject.where(id: @subproject.id), 4.days.ago,
                                                              Time.current)

    assert_kind_of LogEntryMetadataService::CategorizedMetadata, result

    assert_equal [], result.numerical
    assert_equal [], result.boolean
  end

  test "returns empty result when no log entries exist" do
    empty_subproject = create(:subproject, project: @project)
    result = @service.retrieve_categorized_metadata_for_range(Subproject.where(id: empty_subproject.id), 4.days.ago,
                                                              Time.current)

    assert_kind_of LogEntryMetadataService::CategorizedMetadata, result

    assert_equal [], result.numerical
    assert_equal [], result.boolean
  end
end
