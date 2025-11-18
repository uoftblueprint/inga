class SubprojectsController < ApplicationController
  before_action :set_project

  def new
    @subproject = @project.subprojects.build
  end

  def create
    @subproject = @project.subprojects.build(subproject_params)

    if @subproject.save
      flash[:success] = "Subproject created successfully."
      redirect_to new_project_subproject_path(@project)
    else
      flash.now[:error] = "Failed to create subproject."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def subproject_params
    params.expect(subproject: %i[name description address region_id])
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
