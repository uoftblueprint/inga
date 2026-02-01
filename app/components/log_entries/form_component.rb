module LogEntries
  class FormComponent < ViewComponent::Base
    attr_reader :project, :subproject, :log_entry

    def initialize(project:, subproject:, log_entry:)
      super()
      @project = project
      @subproject = subproject
      @log_entry = log_entry
    end
  end
end
