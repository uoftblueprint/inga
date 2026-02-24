module Shared
  class IndexTableComponent < ViewComponent::Base
    attr_reader :records, :columns, :searchable, :per_page

    Column = Struct.new(:attribute, :header, :cell_renderer, :col_size, :sortable, :default_sort, :default_direction)

    def initialize(records:, searchable: true, per_page: 10)
      super()
      @records = records
      @columns = []
      @searchable = searchable
      @per_page = per_page
    end

    def column(attribute, header: nil, col_size: nil, sortable: true, default_sort: false, default_direction: :desc,
               &cell_renderer)
      label = header || default_header_for(attribute)
      sortable = false if attribute == :actions
      @columns << Column.new(attribute, label, cell_renderer, col_size, sortable, default_sort, default_direction)
    end

    private

    def render_cell_content(record, column)
      if column.cell_renderer
        view_context.capture(record, &column.cell_renderer)
      else
        record.send(column.attribute)
      end
    end

    def sort_value_for(record, column)
      return nil if column.cell_renderer

      value = record.send(column.attribute)
      return value.to_i if value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(Date)

      nil
    end

    def before_render
      content
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

    def sort_column_index
      @sort_column_index ||= columns.find_index(&:default_sort) ||
                             columns.find_index { |c| c.attribute == :created_at } ||
                             columns.find_index(&:sortable) ||
                             -1
    end

    def sort_direction
      @sort_direction ||= if sort_column_index >= 0
                            columns[sort_column_index].default_direction || :desc
                          else
                            :asc
                          end
    end
  end
end
