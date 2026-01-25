module ProjectAttributes
  class LogAttributeComponent < ViewComponent::Base
    attr_reader :title, :type

    def initialize(title: nil, type: nil)
      @title = title
      @type = type
      super()
    end

    private

    def selected?(option_type)
      type == option_type
    end
  end
end
