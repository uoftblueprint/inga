module Shared
  class IndexTableComponent < ViewComponent::Base
    attr_reader :records, :columns, :searchable

    Column = Struct.new(:attribute, :header, :cell_renderer)

    def initialize(records:, searchable: true)
      super()
      @records = records
      @columns = []
      @searchable = searchable
    end

    def column(attribute, header: nil, &cell_renderer)
      @columns << Column.new(attribute, header || attribute.to_s.humanize, cell_renderer)
    end

    private

    def render_cell_content(record, column)
      if column.cell_renderer
        view_context.capture(record, &column.cell_renderer)
      else
        record.send(column.attribute)
      end
    end

    def before_render
      content
    end
  end
end
