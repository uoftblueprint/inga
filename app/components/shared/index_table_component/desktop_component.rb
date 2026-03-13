module Shared
  class IndexTableComponent
    class DesktopComponent < ViewComponent::Base
      attr_reader :records, :columns, :column_sizes, :empty_state_text, :cell_content_renderer

      def initialize(records:, columns:, column_sizes:, empty_state_text:, cell_content_renderer:)
        super()
        @records = records
        @columns = columns
        @column_sizes = column_sizes
        @empty_state_text = empty_state_text
        @cell_content_renderer = cell_content_renderer
      end
    end
  end
end
