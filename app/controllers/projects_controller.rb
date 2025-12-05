class ProjectsController < ApplicationController
  def show
    @project = Project.find(params[:id])
  end

  private

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
