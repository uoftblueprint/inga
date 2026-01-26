module Regions
  class FormComponent < ViewComponent::Base
    attr_reader :region

    def initialize(region:)
      super()
      @region = region
    end
  end
end
