module Services
  class LogEntryMetadataService
    CategorizedMetadata = Struct.new(:numerical, :boolean) do
      def initialize(numerical = [], boolean = [])
        super
      end
    end

    def retrieve_categorized_metadata_for_range(subprojects, start_date, end_date)
      logs_with_schemas = fetch_log_entries_with_schemas(subprojects, start_date, end_date)

      categorized_metadata_for(logs_with_schemas)
    end

    private

    def fetch_log_entries_with_schemas(subprojects, start_date, end_date)
      LogEntry
        .where(subproject_id: subprojects.ids)
        .where(created_at: start_date..end_date)
        .includes(subproject: :project)
        .map do |log_entry|
          {
            log_entry: log_entry,
            log_schema: log_entry.subproject.project.log_schema
          }
        end
    end

    def categorized_metadata_for(logs_with_schemas)
      result = CategorizedMetadata.new

      # cache the numerical and boolean fields for each project as we encounter
      # them to avoid redundant lookups
      fields_by_project_id = {}

      logs_with_schemas.each do |entry_with_schema|
        log_entry = entry_with_schema[:log_entry]
        log_schema = entry_with_schema[:log_schema]

        project = log_entry.subproject.project
        project_id = project.id

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
end
