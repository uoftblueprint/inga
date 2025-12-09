class ProjectsController < ApplicationController
  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new(active: true)
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to(project_path(@project), flash: { success: t(".success") })
    else
      flash.now[:error] = t(".error")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def project_params
    params.expect(project: %i[name description active])
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
