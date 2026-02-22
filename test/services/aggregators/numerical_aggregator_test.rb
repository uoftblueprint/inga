require "test_helper"

module Aggregators
  class NumericalAggregatorTest < ActiveSupport::TestCase
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

    test "inserts the correct aggregations for the data" do
      NumericalAggregator.new(report: @report, data: @categorized_metadata.numerical).aggregate

      data = AggregatedNumericalDatum.where(report: @report).order(:id).map do |datum|
        {
          value: datum.value,
          additional_text: datum.additional_text
        }
      end

      assert_equal 3, data.size
      assert_equal [{ value: 138.0, additional_text: "Total Trees Planted" },
                    { value: 46.0, additional_text: "Average Trees Planted per log entry" },
                    { value: 27.6, additional_text: "Average Trees Planted per day" }], data
    end

    test "returns nothing when no data is provided" do
      NumericalAggregator.new(report: @report, data: LogEntryMetadataService::CategorizedMetadata.new).aggregate

      data = AggregatedNumericalDatum.where(report: @report)

      assert_equal 0, data.size
    end
  end
end
