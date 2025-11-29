class ProjectsController < ApplicationController
  def new
    @project = Project.new
  end

  def create
    @project = Project.new(new_params)
    @project.active = true

    if @project.save
      redirect_to(@project, notice: t(".create.success"))
    else
      flash.now[:error] = t(".create.error")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def new_params
    params.expect(project: %i[name description])
  end

  def has_required_roles? = true
end
