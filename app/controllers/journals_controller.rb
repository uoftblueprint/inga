class JournalsController < ApplicationController
  before_action :set_project_subproject

  def index
    @journals = @subproject.journals.all
  end

  def show
    @journal = @subproject.journals.find(params[:id])
  end

  def new
    @journal = @subproject.journals.build
  end

  def edit
    @journal = @subproject.journals.find(params[:id])
  end

  def create
    @journal = @subproject.journals.build(journal_params)
    @journal.user = current_user

    if @journal.save
      redirect_to(
        project_subproject_journal_path(@project, @subproject, @journal),
        flash: { success: t(".success") }
      )
    else
      flash.now[:error] = @journal.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @journal = @subproject.journals.find(params[:id])

    if @journal.update(journal_params)
      redirect_to(
        project_subproject_journal_path(@project, @subproject, @journal),
        flash: { success: t(".success") }
      )
    else
      flash.now[:error] = @journal.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity

    end
  end

  def destroy
    @journal = @subproject.journals.find(params[:id])

    if @journal.destroy
      redirect_to(
        project_subproject_journals_path(@project, @subproject),
        flash: { success: t(".success") }
      )
    else
      redirect_to(
        project_subproject_journal_path(@project, @subproject, @journal),
        flash: { error: @journal.errors.full_messages.to_sentence }
      )
    end
  end

  private

  def set_project_subproject
    @project = Project.find(params[:project_id])
    @subproject = @project.subprojects.find(params[:subproject_id])
  end

  def journal_params
    params.expect(journal: %i[markdown_content])
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
