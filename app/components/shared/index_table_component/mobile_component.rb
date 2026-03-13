module Shared
  class IndexTableComponent
    class MobileComponent < ViewComponent::Base
      attr_reader :records, :columns, :empty_state_text, :cell_content_renderer

      def initialize(records:, columns:, empty_state_text:, cell_content_renderer:)
        super()
        @records = records
        @columns = columns
        @empty_state_text = empty_state_text
        @cell_content_renderer = cell_content_renderer
      end

      def content_columns
        columns.reject { |column| action_column?(column) }
      end

      def actions_column
        columns.find { |column| action_column?(column) }
      end

      private

      def action_column?(column)
        column.attribute.to_sym == :actions
      end
    end
  end
end
