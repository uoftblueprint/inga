module Journals
  class JournalFormComponent < ViewComponent::Base
    attr_reader :project, :subproject, :journal

    delegate_missing_to :helpers

    def initialize(project:, subproject:, journal:)
      super()
      @project = project
      @subproject = subproject
      @journal = journal
    end
  end
end
