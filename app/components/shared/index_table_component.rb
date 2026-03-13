module Shared
  class IndexTableComponent < ViewComponent::Base
    attr_reader :records, :columns, :searchable, :per_page

    Column = Struct.new(:attribute, :header, :cell_renderer, :col_size)

    def initialize(records:, searchable: true, per_page: 10)
      super()
      @records = records
      @columns = []
      @searchable = searchable
      @per_page = per_page
    end

    def column(attribute, header: nil, col_size: nil, &cell_renderer)
      label = header || default_header_for(attribute)
      @columns << Column.new(attribute, label, cell_renderer, col_size)
    end

    def column_sizes
      @column_sizes ||= columns.map { |column| column.col_size || "minmax(0, 1fr)" }.join(" ")
    end

    def empty_state_text
      t("shared.index_table_component.no_entries")
    end

    def cell_content_renderer
      method(:render_cell_content)
    end

    private

    def render_cell_content(record, column)
      if column.cell_renderer
        view_context.capture(record, &column.cell_renderer)
      else
        record.send(column.attribute)
      end
    end

    def model_class
      # memoize to only have to compute value once per table
      return @model_class if instance_variable_defined?(:@model_class)

      @model_class = if records.respond_to?(:model) # for models
                       records.model
                     elsif records.respond_to?(:klass) # for relations
                       records.klass
                     end
    end

    def default_header_for(attribute)
      klass = model_class

      if klass.respond_to?(:human_attribute_name)
        klass.human_attribute_name(attribute)
      else
        attribute.to_s.humanize
      end
    end

    def empty? = records.empty?

    def before_render
      content
    end
  end
end
