class ProjectAttributesController < ApplicationController
  def edit = @project = Project.find(params[:project_id])

  def update
    @project = Project.find(params[:project_id])

    if @project.replace_log_attributes(*params.require(:attributes))
      flash[:success] = t(".success")
      redirect_to project_path(@project), status: :see_other
    else
      flash.now[:error] = @project.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def new_row
    render turbo_stream: turbo_stream.append(
      "project_attributes_list",
      ProjectAttributes::LogAttributeComponent.new(title: "New Attribute", type: "numerical")
    )
  end

  private

  def has_required_roles? = current_user.has_roles?(:admin)
end
