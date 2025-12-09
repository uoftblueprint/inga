module Projects
  class ProjectFormComponent < ViewComponent::Base
    attr_reader :project

    def initialize(project:)
      @project = project
      super()
    end
  end
end
