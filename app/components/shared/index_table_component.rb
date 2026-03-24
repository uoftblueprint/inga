module Shared
  class IndexTableComponent < ViewComponent::Base
    attr_reader :records, :columns, :searchable, :per_page, :actions, :clickable_rows, :turbo_stream_rows

    Column = Struct.new(:attribute, :header, :cell_renderer, :col_size)

    def initialize(records:, searchable: true, per_page: 10, actions: nil, clickable_rows: true,
                   turbo_stream_rows: false)
      super()
      @records = records
      @columns = []
      @searchable = searchable
      @per_page = per_page
      @actions = actions
      @clickable_rows = clickable_rows
      @turbo_stream_rows = turbo_stream_rows
    end

    def row_path_for(record)
      if @turbo_stream_rows
        polymorphic_path(record.to_polymorphic_path, format: :turbo_stream)
      else
        polymorphic_path(record.to_polymorphic_path)
      end
    end

    def column(attribute, header: nil, col_size: nil, &cell_renderer)
      label = header || default_header_for(attribute)
      @columns << Column.new(attribute, label, cell_renderer, col_size)
    end

    def has_actions?
      @actions.present?
    end

    def actions_for(record)
      return [] unless has_actions?

      @actions.call(record)
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
