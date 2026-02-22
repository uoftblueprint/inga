module Aggregators
  class BaseAggregator
    def initialize(report:, data:)
      @aggregation_methods = []
      @report = report
      @data = data
    end

    def aggregate
      @aggregation_methods.each do |method|
        send(method)
      end
    end
  end
end
