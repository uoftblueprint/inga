module Shared
  class IndexTableComponent < ViewComponent::Base
    attr_reader :records

    def initialize(records:)
      super()
      @records = records
    end

    private

    def headers
      return [] if @records.empty?

      @records.first.attributes.keys.map(&:humanize)
    end

    def render_cell_content(value:)
      if value.is_a? IndexTableComponentCell
        render value
      else
        value.to_s
      end
    end
  end
end
