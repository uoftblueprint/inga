module Reports
  class AggregatedDatumCardComponent < ViewComponent::Base
    attr_reader :aggregated_datum

    def initialize(aggregated_datum:)
      super()
      @aggregated_datum = aggregated_datum
    end
  end
end
