module Aggregators
  class BooleanAggregator < BaseAggregator
    def aggregate
      # TODO: make this add the appropriate entries to AggregatedData based on
      # all possible aggregations for this type
      raise NotImplementedError
    end
  end
end
