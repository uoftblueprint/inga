class ProjectsController < ApplicationController
  def index
    @projects = Project.all
  end

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

  def destroy
    @project = Project.find(params[:id])
    if @project.destroy
      redirect_to(projects_path, flash: { success: t(".success") })
    else
      redirect_to(projects_path, flash: { error: @project.errors.full_messages.to_sentence })
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
