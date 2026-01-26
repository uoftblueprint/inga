module Journals
  class FormComponent < ViewComponent::Base
    attr_reader :project, :subproject, :journal, :title

    delegate_missing_to :helpers

    def initialize(project:, subproject:, journal:, title: nil)
      super()
      @project = project
      @subproject = subproject
      @journal = journal
      @title = title
    end
  end
end
