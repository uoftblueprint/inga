class ProjectAttributesController < ApplicationController
  def edit
    @project = Project.find(params[:project_id])
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new_row
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "project_attributes_list",
          ProjectAttributes::LogAttributeComponent.new(title: "", type: "text")
        )
      end
    end
  end

  def update
    @project = Project.find(params[:project_id])
    if @project.replace_log_attributes(*project_params[:log_attributes])
      redirect_to @project, flash: { success: t(".success") }
    else
      flash.now[:error] = @project.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def project_params
    params.require(:project).permit(log_attributes: %i[title type]) # rubocop:disable Rails/StrongParametersExpect
  end

  def has_required_roles? = current_user.has_roles?(:admin)
end
