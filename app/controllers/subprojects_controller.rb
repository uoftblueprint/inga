class SubprojectsController < ApplicationController
  before_action :set_project
  before_action :set_regions, only: %i[new create]

  def new
    @subproject = @project.subprojects.build
  end

  def create
    @subproject = @project.subprojects.build(subproject_params)

    if @subproject.save
      redirect_to [@project, @subproject]
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_regions
    @regions = Region.all
  end

  def subproject_params
    params.expect(subproject: %i[name description address region_id])
  end

  def has_required_roles? = true
end
