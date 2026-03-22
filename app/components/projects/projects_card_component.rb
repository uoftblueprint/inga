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
        { text: t("status.active", scope: "projects.projects_card_component"), colour: :primary }
      else
        { text: t("status.inactive", scope: "projects.projects_card_component"), colour: :error }
      end
    end
  end
end
