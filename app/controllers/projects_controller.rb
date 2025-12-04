class ProjectsController < ApplicationController
  def new
    @project = Project.new(active: true)
  end

  def create
    @project = Project.new(new_params)

    if @project.save
      redirect_to(@project, notice: t(".create.success"))
    else
      flash.now[:error] = t(".create.error")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def new_params
    params.require(:project).permit(:name, :description, :active)
  end

  def has_required_roles? 
    current_user.has_roles?(:admin)
  end
end
