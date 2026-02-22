require "test_helper"

module Aggregators
  class BooleanAggregatorTest < ActiveSupport::TestCase
    setup do
      @project = create(:project, log_schema: { "Trees Planted" => "numerical", "Flagged" => "boolean" })
      @subproject = create(:subproject, project: @project)

      create(:log_entry, subproject: @subproject, metadata: { "Trees Planted" => 43,
                                                              "Flagged" => true }, created_at: 3.days.ago)
      create(:log_entry, subproject: @subproject, metadata: { "Trees Planted" => 45,
                                                              "Flagged" => false }, created_at: 2.days.ago)
      create(:log_entry, subproject: @subproject, metadata: { "Trees Planted" => 50,
                                                              "Flagged" => true }, created_at: 1.day.ago)

      service = LogEntryMetadataService.new
      @categorized_metadata = service.retrieve_categorized_metadata_for_range(Subproject.where(id: @subproject.id),
                                                                              4.days.ago, Time.current)

      @report = create(:report, start_date: 4.days.ago.to_date, end_date: Time.current.to_date)
    end

    test "returns correct aggregations for the data" do
      BooleanAggregator.new(report: @report, data: @categorized_metadata.boolean).aggregate

      data = AggregatedBooleanDatum.where(report: @report).order(:id).map do |datum|
        {
          value: datum.value,
          additional_text: datum.additional_text
        }
      end

      assert_equal 3, data.size
      assert_equal [{ value: 2.0, additional_text: "True instances of Flagged" },
                    { value: 0.6666666666666666, additional_text: "Average true instances of Flagged per log entry" },
                    { value: 0.4, additional_text: "Average true instances of Flagged per day" }], data
    end

    test "returns nothing when no data is provided" do
      BooleanAggregator.new(report: @report, data: LogEntryMetadataService::CategorizedMetadata.new).aggregate

      data = AggregatedBooleanDatum.where(report: @report)

      assert_equal 0, data.size
    end
  end
end
