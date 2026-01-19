class JournalsController < ApplicationController
  def index
    @journals = Journal.all
  end

  def show
    @journal = Journal.find(params[:id])
  end

  def new
    @journal = Journal.new
  end

  def edit
    @journal = Journal.find(params[:id])
  end

  def create
    @journal = Journal.new(journal_attributes)
    @journal.user = current_user

    if @journal.save
      images = journal_images
      @journal.images.attach(images) if images.present?
      redirect_to(journal_path(@journal), flash: { success: t(".success") })
    else
      flash.now[:error] = @journal.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @journal = Journal.find(params[:id])

    if @journal.update(journal_attributes)
      images = journal_images
      @journal.images.attach(images) if images.present?
      redirect_to(journal_path(@journal), flash: { success: t(".success") })
    else
      flash.now[:error] = @journal.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @journal = Journal.find(params[:id])

    if @journal.destroy
      redirect_to(journals_path, flash: { success: t(".success") })
    else
      redirect_to(journals_path, flash: { error: @journal.errors.full_messages.to_sentence })
    end
  end

  private

  def journal_attributes
    params.expect(journal: %i[markdown_content subproject_id])
  end

  def journal_images
    params.dig(:journal, :images)
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
