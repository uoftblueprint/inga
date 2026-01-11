module Home
  class ProjectsCardComponent < ViewComponent::Base
    attr_reader :projects

    def initialize(projects:)
      super()
      @projects = projects
    end

    private

    def subproject_text(project)
      subproject_count = project.subprojects.count
      "#{subproject_count} Subproject#{'s' unless subproject_count == 1}"
    end

    def project_badge_args(project)
      if project.active
        { text: "Active", colour: :success }
      else
        { text: "Inactive", colour: :warning }
      end
    end
  end
end
