class ProjectsController < ApplicationController
  def index
    @projects = Project.includes(subprojects: :region).all
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new(active: true)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to(project_path(@project), flash: { success: t(".success") })
    else
      flash.now[:error] = @project.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @project = Project.find(params[:id])

    if @project.update(project_params)
      redirect_to(project_path(@project), flash: { success: t(".success") })
    else
      flash.now[:error] = @project.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
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
