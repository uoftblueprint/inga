class JournalsController < ApplicationController
  def new
    @projects = Project.all
    @project = nil
    @subproject = nil
    @journal = Journal.new
  end

  def create
    @project = Project.find(params[:journal][:project_id])
    @subproject = @project.subprojects.find(params[:journal][:subproject_id])
    @journal = @subproject.journals.build(journal_params)
    @journal.user = current_user

    if @journal.save
      redirect_to(
        project_subproject_journal_path(@project, @subproject, @journal),
        flash: { success: t(".success") }
      )
    else
      @projects = Project.all
      flash.now[:error] = @journal.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to new_journal_path, flash: { error: t(".invalid_project_subproject") }
  end

  private

  def journal_params
    params.expect(journal: %i[title markdown_content])
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
