module Journals
  class FormComponent < ViewComponent::Base
    attr_reader :project, :subproject, :journal, :url

    delegate_missing_to :helpers

    def initialize(project:, subproject:, journal:, url: nil)
      super()
      @project = project
      @subproject = subproject
      @journal = journal
      @url = url
    end
  end
end
