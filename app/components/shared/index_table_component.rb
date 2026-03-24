module Shared
  class IndexTableComponent < ViewComponent::Base
    attr_reader :records, :columns, :searchable, :per_page, :clickable_rows, :turbo_stream_rows

    Column = Struct.new(:attribute, :header, :cell_renderer, :col_size)

    def initialize(records:, searchable: true, per_page: 10, clickable_rows: true,
                   turbo_stream_rows: false, record_path: nil)
      super()
      @records = records
      @columns = []
      @searchable = searchable
      @per_page = per_page
      @clickable_rows = clickable_rows
      @turbo_stream_rows = turbo_stream_rows
      @record_path = record_path
    end

    def column(attribute, header: nil, col_size: nil, &cell_renderer)
      label = header || default_header_for(attribute)
      @columns << Column.new(attribute, label, cell_renderer, col_size)
    end

    private

    def row_path_for(record)
      return nil unless @record_path

      path = @record_path.call(record)

      return path unless @turbo_stream_rows

      path.include?("?") ? "#{path}&format=turbo_stream" : "#{path}?format=turbo_stream"
    end

    def row_link_data
      { turbo_stream: (@turbo_stream_rows ? true : nil) }.compact
    end

    def render_cell_wrapper(record, column, classes:, &)
      if row_clickable_for?(record, column)
        link_to(row_path_for(record), data: row_link_data, class: classes, &)
      else
        content_tag(:div, class: classes, &)
      end
    end

    def row_clickable_for?(record, column)
      clickable_rows && row_path_for(record).present? && column.attribute != :actions
    end

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
