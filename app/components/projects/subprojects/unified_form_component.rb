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

        @selected_project = selected_project_id.present? ? Project.find_by(id: selected_project_id) : nil
        @selected_subproject = if @selected_project && selected_subproject_id.present?
                                 @selected_project.subprojects.find_by(id: selected_subproject_id)
                               end

        super()
      end

      def selection_complete?
        selected_project.present? && selected_subproject.present?
      end

      def step_1_animation_class
        turbo_frame_request? ? nil : "ui-enter-item"
      end

      private

      def turbo_frame_request?
        helpers.request.headers["Turbo-Frame"].present?
      end
    end
  end
end
