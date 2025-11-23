module Shared
  class IndexTableComponentCell < ViewComponent::Base
    attr_reader :record

    def initialize(record:)
      super()
      @record = record
    end
  end
end
