module Shared
  class IndexTableComponent < ViewComponent::Base
    attr_reader :records, :columns, :searchable, :per_page, :clickable_rows, :turbo_stream_rows

    Column = Struct.new(:attribute, :header, :cell_renderer, :col_size, :sortable, :default_sort, :default_direction)

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

    def column(attribute, header: nil, col_size: nil, sortable: true, default_sort: false,
               default_direction: :desc, &cell_renderer)
      label = header || default_header_for(attribute)
      sortable = false if attribute == :actions
      @columns << Column.new(attribute, label, cell_renderer, col_size, sortable, default_sort, default_direction)
    end

    private

    def turbo_stream_url_for(path)
      uri = URI.parse(path.to_s)
      params = Rack::Utils.parse_nested_query(uri.query).merge("format" => "turbo_stream")

      uri.query = params.to_query.presence

      uri.to_s
    end

    def row_path_for(record)
      return nil unless @record_path

      path = @record_path.call(record)

      return path unless @turbo_stream_rows

      turbo_stream_url_for(path)
    end

    def row_link_data
      { turbo_stream: (@turbo_stream_rows ? true : nil) }.compact
    end

    def row_clickable?(record)
      clickable_rows && row_path_for(record).present?
    end

    def row_overlay_link(record)
      return unless row_clickable?(record)

      link_to(
        row_path_for(record),
        data: row_link_data,
        class: "absolute inset-0 rounded-lg z-10"
      ) do
        content_tag(:span)
      end
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

    def sort_value_for(record, column)
      return nil unless record.respond_to?(column.attribute)

      value = record.send(column.attribute)
      case value
      when Time, DateTime
        return value.to_i.to_s
      when Date
        return value.to_time.to_i.to_s
      when Numeric
        return value.to_f.to_s
      end

      nil
    end

    def sort_column_index
      @sort_column_index ||= columns.find_index(&:default_sort) || -1
    end

    def sort_direction
      @sort_direction ||= if sort_column_index >= 0
                            columns[sort_column_index].default_direction || :desc
                          else
                            :asc
                          end
    end

    def before_render
      content
    end
  end
end
