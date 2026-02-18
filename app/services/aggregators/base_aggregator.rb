module Aggregators
  class BaseAggregator
    def initialize(data:)
      # NOTE: data is expected to be a struct with the following format:
      # { numerical: [{ field_name: value, ... }, ...], boolean: [{ field_name: value, ... }, ...] }
      @data = data
    end

    def aggregate
      raise NotImplementedError
    end
  end
end
