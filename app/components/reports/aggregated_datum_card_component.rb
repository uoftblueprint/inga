module Reports
  class AggregatedDatumCardComponent < ViewComponent::Base
    attr_reader :aggregated_datum

    def initialize(aggregated_datum:, static: false)
      super()
      @aggregated_datum = aggregated_datum
      @static = static
    end
  end
end
