class SubprojectsController < ApplicationController
  before_action :set_project

  def index
    @subprojects = @project.subprojects
    @subprojects = @subprojects.where("LOWER(name) LIKE ?", "%#{params[:name].downcase}%") if params[:name].present?
  end

  def show
    @subproject = @project.subprojects.find(params[:id])
  end

  def new
    @subproject = @project.subprojects.build
  end

  def edit
    @subproject = @project.subprojects.find(params[:id])
  end

  def create
    @subproject = @project.subprojects.build(subproject_params)

    if @subproject.save
      redirect_to(
        new_project_subproject_path(@project),
        flash: { success: "Subproject created successfully." }
      )
    else
      flash.now[:error] = "Failed to create subproject." # rubocop:disable Rails/I18nLocaleTexts
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
      flash.now[:error] = t(".error")
      render :edit, status: :unprocessable_entity
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
