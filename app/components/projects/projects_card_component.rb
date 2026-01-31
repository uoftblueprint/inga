module Projects
  class ProjectsCardComponent < ViewComponent::Base
    attr_reader :projects

    def initialize(projects:)
      super()
      @projects = projects
    end

    private

    def project_badge_args(project)
      if project.active
        { text: t(".status.active"), colour: :success }
      else
        { text: t(".status.inactive"), colour: :warning }
      end
    end
  end
end
