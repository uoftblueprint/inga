module Projects
  class LogSchemaComponent < ViewComponent::Base
    attr_reader :project

    def initialize(project:)
      super()
      @project = project
    end
  end
end
