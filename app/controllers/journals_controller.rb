class JournalsController < ApplicationController
  before_action :set_project_subproject, except: %i[new create]

  def show
    @journal = @subproject.journals.includes(:user).find(params[:id])
  end

  def new
    if params[:project_id].present? && params[:subproject_id].present?
      set_project_subproject
      @journal = @subproject.journals.build
    else
      @projects = Project.includes(:subprojects).order(:name)
      @journal = Journal.new
    end
  end

  def edit
    @journal = @subproject.journals.find(params[:id])
  end

  def create
    if params[:project_id].present? && params[:subproject_id].present?
      set_project_subproject
      @journal = @subproject.journals.build(journal_params)
    else
      @project = Project.find_by(id: params.dig(:journal, :project_id))
      @subproject = @project&.subprojects&.find_by(id: params.dig(:journal, :subproject_id))
      @journal = @subproject&.journals&.build(journal_params) || Journal.new(journal_params)
      @projects = Project.includes(:subprojects).order(:name)
    end

    @journal.user = current_user

    if @journal.save
      redirect_to(
        project_subproject_journal_path(@project, @subproject, @journal),
        flash: { success: t(".success") }
      )
    else
      flash.now[:error] = @journal.errors.full_messages.to_sentence.presence
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
        project_subproject_path(@project, @subproject),
        flash: { success: t(".success") }
      )
    else
      redirect_to(
        project_subproject_path(@project, @subproject),
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
    params.expect(journal: %i[title markdown_content])
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
