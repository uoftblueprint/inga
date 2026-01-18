# frozen_string_literal: true

module Subprojects
  class SubprojectModalComponent < ViewComponent::Base
    include ActionView::RecordIdentifier

    attr_reader :project, :subproject, :button_text

    def initialize(project:, subproject: nil, button_text: nil)
      super()
      @project = project
      @subproject = subproject || project.subprojects.build
      @button_text = button_text || I18n.t("projects.show.create_subproject", default: "Create Subproject")
    end

    def modal_id
      dom_id(project, :subproject_modal)
    end

    def form_dom_id
      dom_id(subproject, :modal_form)
    end
  end
end
