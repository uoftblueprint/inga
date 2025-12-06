module Regions
  class RegionFormComponent < ViewComponent::Base
    attr_reader :region

    def initialize(region:)
      super()
      @region = region
    end
  end
end
