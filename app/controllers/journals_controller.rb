class JournalsController < ApplicationController
  def new
    @projects = Project.all
    @journal = Journal.new

    return unless params[:project_id].present?

    @project = Project.find_by(id: params[:project_id])
    return unless @project.present? && params[:subproject_id].present?

    @subproject = @project.subprojects.find_by(id: params[:subproject_id])
  end

  def has_required_roles? = current_user.has_roles?(:admin)
end
