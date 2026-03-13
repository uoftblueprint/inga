module LogEntries
  class MetadataInputComponent < ViewComponent::Base
    attr_reader :title, :type, :log_entry

    def initialize(title:, type:, log_entry:)
      super()
      @title = title
      @type = type
      @log_entry = log_entry
    end

    def value
      log_entry.metadata && log_entry.metadata[title]
    end
  end
end
