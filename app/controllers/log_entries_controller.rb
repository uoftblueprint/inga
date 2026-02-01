class LogEntriesController < ApplicationController
  before_action :set_project_subproject

  def new
    @log_entry = @subproject.log_entries.build

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    @log_entry = @subproject.log_entries.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    raw_metadata = log_entry_params.fetch(:metadata, {})

    converted = {}

    @project.log_schema.each do |title, type|
      raw = raw_metadata[title]
      converted[title] = convert_by_type(type, raw)
    end

    @log_entry = @subproject.log_entries.build(metadata: converted)
    @log_entry.user = current_user

    if @log_entry.save
      # TODO: potentially change to log entry view path
      redirect_to(project_subproject_path(@project, @subproject), flash: { success: t(".success") })
    else
      redirect_to(project_subproject_path(@project, @subproject),
                  flash: { error: @log_entry.errors.full_messages.to_sentence })
    end
  end

  def update
    @log_entry = @subproject.log_entries.find(params[:id])

    raw_metadata = log_entry_params.fetch(:metadata, {})

    converted = {}
    @project.log_schema.each do |title, type|
      raw = raw_metadata[title]
      converted[title] = convert_by_type(type, raw)
    end

    if @log_entry.update(metadata: converted)
      # TODO: potentially change to log entry view path
      redirect_to(project_subproject_path(@project, @subproject), flash: { success: t(".success") })
    else
      redirect_to(project_subproject_path(@project, @subproject),
                  flash: { error: @log_entry.errors.full_messages.to_sentence })
    end
  end

  private

  def set_project_subproject
    @project = Project.find(params[:project_id])
    @subproject = @project.subprojects.find(params[:subproject_id])
  end

  def log_entry_params
    params.expect(log_entry: [metadata: {}])
  end

  def convert_by_type(type, raw)
    return nil if raw.blank?

    case type.to_s
    when "numerical"
      Float(raw)
    when "boolean"
      return true if raw == "on"
      return false if raw == "off"

      nil
    else
      raw
    end
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
