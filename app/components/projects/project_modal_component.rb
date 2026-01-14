module Projects
  class ProjectModalComponent < ViewComponent::Base
    attr_reader :project, :title, :id

    def initialize(project:, title: "Create project", id: "project-modal")
      super()
      @project = project
      @title = title
      @id = id
    end
  end
end
