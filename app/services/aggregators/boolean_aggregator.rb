module Aggregators
  class BooleanAggregator < BaseAggregator
    def initialize(report:, data:)
      super

      @aggregation_methods = %i[true_instances average_true_instances_per_log_entry average_true_instances_per_day]
    end

    private

    def true_instances
      combined_instances.each do |key, value|
        AggregatedBooleanDatum.create(value: value, report: @report, additional_text: "True instances of #{key}")
      end
    end

    def average_true_instances_per_log_entry
      data_size = @data.size

      combined_instances.each do |key, value|
        AggregatedBooleanDatum.create(value: value.to_f / data_size, report: @report,
                                      additional_text: "Average true instances of #{key} per log entry")
      end
    end

    def average_true_instances_per_day
      num_days = (@report.end_date - @report.start_date).to_i + 1

      combined_instances.each do |key, value|
        AggregatedBooleanDatum.create(value: value.to_f / num_days, report: @report,
                                      additional_text: "Average true instances of #{key} per day")
      end
    end

    def combined_instances
      result = Hash.new(0)

      @data.each do |entry|
        entry.each do |key, value|
          result[key] += 1 if value
        end
      end

      result
    end
  end
end
