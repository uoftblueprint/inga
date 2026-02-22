module Aggregators
  class NumericalAggregator < BaseAggregator
    def initialize(report:, data:)
      super

      @aggregation_methods = %i[sum average_per_log_entry average_per_day]

      @combined_sums = combined_sums
    end

    private

    def sum
      @combined_sums.each do |key, value|
        AggregatedNumericalDatum.create(value: value, report: @report, additional_text: "Total #{key}")
      end
    end

    def average_per_log_entry
      data_size = @data.size

      return unless data_size > 0

      @combined_sums.each do |key, value|
        AggregatedNumericalDatum.create(value: value.to_f / data_size, report: @report,
                                        additional_text: "Average #{key} per log entry")
      end
    end

    def average_per_day
      num_days = (@report.end_date - @report.start_date).to_i + 1

      return unless num_days > 0

      @combined_sums.each do |key, value|
        AggregatedNumericalDatum.create(value: value.to_f / num_days, report: @report,
                                        additional_text: "Average #{key} per day")
      end
    end

    def combined_sums
      result = Hash.new(0)

      @data.each do |entry|
        entry.each { |key, value| result[key] += value }
      end

      result
    end
  end
end
