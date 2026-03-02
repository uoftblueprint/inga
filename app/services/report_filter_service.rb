class ReportFilterService
  FilterResult = Struct.new(
    :projects, :selected_project_ids, :subprojects, :selected_subproject_ids, keyword_init: true
  )

  def filter(start_date:, end_date:, project_ids: [], subproject_ids: [])
    date_range = start_date.beginning_of_day..end_date.end_of_day

    projects = Project.joins(subprojects: :log_entries)
                      .where(log_entries: { created_at: date_range })
                      .distinct

    selected_project_ids = project_ids.map(&:to_i) & projects.pluck(:id)

    subprojects = nil
    selected_subproject_ids = []

    if selected_project_ids.present?
      subprojects = Subproject.where(project_id: selected_project_ids)
                              .joins(:log_entries)
                              .where(log_entries: { created_at: date_range })
                              .distinct

      selected_subproject_ids = subproject_ids.map(&:to_i) & subprojects.pluck(:id)
    end

    FilterResult.new(
      projects: projects,
      selected_project_ids: selected_project_ids,
      subprojects: subprojects,
      selected_subproject_ids: selected_subproject_ids
    )
  end
end
