class SubprojectsController < ApplicationController
  before_action :set_project

  def show
    @subproject = @project.subprojects.includes(log_entries: :user, journals: :user).find(params[:id])
  end

  def new
    @subproject = @project.subprojects.build

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    @subproject = @project.subprojects.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @subproject = @project.subprojects.build(subproject_params)

    if @subproject.save
      redirect_to(
        new_project_subproject_path(@project),
        flash: { success: t(".success") }
      )
    else
      flash.now[:error] = @subproject.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @subproject = @project.subprojects.find(params[:id])

    if @subproject.update(subproject_params)
      redirect_to(
        project_subproject_path(@project, @subproject),
        flash: { success: t(".success") }
      )
    else
      flash.now[:error] = @subproject.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subproject = @project.subprojects.find(params[:id])

    if @subproject.destroy
      redirect_to(
        project_path(@project),
        flash: { success: t(".success") }
      )
    else
      redirect_to(
        project_path(@project),
        flash: { error: @subproject.errors.full_messages.to_sentence }
      )
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
