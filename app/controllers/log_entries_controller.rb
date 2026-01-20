class LogEntriesController < ApplicationController
  before_action :require_login
  before_action :set_subproject

  # POST /projects/:project_id/subprojects/:subproject_id/log_entries
  def create
    @log_entry = @subproject.log_entries.build(log_entry_params)
    @log_entry.user = current_user

    if @log_entry.save
      render json: @log_entry, status: :created
    else
      render json: { errors: @log_entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_subproject
    project = Project.find(params[:project_id])
    @subproject = project.subprojects.find(params[:subproject_id])
  end

  def log_entry_params
    params.expect(log_entry: [:datetime, { metadata: {} }])
  end

  def has_required_roles?
    true
  end
end
