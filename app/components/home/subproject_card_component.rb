module Home
  class SubprojectCardComponent < ViewComponent::Base
    attr_reader :subproject

    def initialize(subproject:)
      super()
      @subproject = subproject
    end
  end
end
