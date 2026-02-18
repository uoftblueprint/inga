class LogEntryMetadataService
  CategorizedMetadata = Struct.new(:numerical, :boolean) do
    def initialize(numerical = [], boolean = [])
      super
    end
  end

  def retrieve_categorized_metadata_for_range(subprojects, start_date, end_date)
    log_entries_in_range = fetch_log_entries_in_range(subprojects, start_date, end_date)

    categorized_metadata_for(log_entries_in_range)
  end

  private

  def fetch_log_entries_in_range(subprojects, start_date, end_date)
    LogEntry
      .where(subproject: subprojects)
      .where(created_at: start_date..end_date)
      .includes(subproject: :project)
  end

  def categorized_metadata_for(log_entries)
    result = CategorizedMetadata.new

    # cache the numerical and boolean fields for each project as we encounter
    # them to avoid redundant lookups
    fields_by_project_id = {}

    log_entries.each do |log_entry|
      project = log_entry.subproject.project

      project_id = project.id
      log_schema = project.log_schema

      next if log_schema.nil?

      unless fields_by_project_id.key?(project_id)
        # in this case the project log schema is being encountered for the
        # first time, so we need to calculate it and store it
        numerical_fields = []
        boolean_fields = []

        log_schema.each do |name, type|
          case type.to_s
          when "numerical"
            numerical_fields << name
          when "boolean"
            boolean_fields << name
          end
        end

        fields_by_project_id[project_id] = {
          numerical: numerical_fields,
          boolean: boolean_fields
        }
      end

      numerical_fields = fields_by_project_id[project_id][:numerical]
      boolean_fields = fields_by_project_id[project_id][:boolean]

      numerical_data = {}
      boolean_data = {}
      metadata = log_entry.metadata || {}

      numerical_fields.each do |field|
        value = metadata[field.to_s]
        numerical_data[field] = value unless value.nil?
      end

      boolean_fields.each do |field|
        value = metadata[field.to_s]
        boolean_data[field] = value unless value.nil?
      end

      result.numerical << numerical_data unless numerical_data.empty?
      result.boolean << boolean_data unless boolean_data.empty?
    end

    result
  end
end
