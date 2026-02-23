module Reports
  class JournalCardComponent < ViewComponent::Base
    attr_reader :journal

    def initialize(journal:)
      super()
      @journal = journal
    end
  end
end
