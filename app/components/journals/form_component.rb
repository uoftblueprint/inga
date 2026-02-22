module Journals
  class FormComponent < ViewComponent::Base
    attr_reader :project, :subproject, :journal, :projects

    def initialize(project:, subproject:, journal:, projects: [])
      super()
      @project = project
      @subproject = subproject
      @journal = journal
      @projects = projects
    end

    # True if this is a top-level journal form (no project/subproject pre-selected)
    def top_level_form?
      project.nil? || subproject.nil?
    end

    # Options for project select
    def project_options
      projects.map { |p| [p.name, p.id] }
    end

    # Grouped options for subproject select
    def grouped_subproject_options
      projects.each_with_object({}) do |entry, hash|
        hash[entry.name] = entry.subprojects.sort_by(&:name).map { |c| [c.name, c.id] }
      end
    end

    # Mapping of project id => array of { id: subproject_id, name: subproject_name }
    def subproject_mapping
      projects.each_with_object({}) do |entry, hash|
        hash[entry.id] = entry.subprojects.sort_by(&:name).map { |c| { id: c.id, name: c.name } }
      end
    end
  end
end
