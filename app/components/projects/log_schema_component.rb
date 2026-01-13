module Projects
  class LogSchemaComponent < ViewComponent::Base
    attr_reader :log_schema

    def initialize(log_schema)
      super()
      @log_schema = log_schema
    end
  end
end
