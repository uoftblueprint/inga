module Projects
  module Subprojects
    class UnifiedFormComponent < ViewComponent::Base
      attr_reader :projects, :form_url, :selected_project_id, :selected_subproject_id

      renders_one :form_body

      def initialize(projects:, form_url:, selected_project_id: nil, selected_subproject_id: nil)
        @projects = projects
        @form_url = form_url
        @selected_project_id = selected_project_id
        @selected_subproject_id = selected_subproject_id
        super()
      end

      def selected_project
        Project.find_by(id: selected_project_id)
      end
    end
  end
end
