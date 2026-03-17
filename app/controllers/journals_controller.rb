class JournalsController < ApplicationController
  def new
    @projects = Project.all
  end

  def form_card
    @journal = Journal.with_rich_text_markdown_content.includes(:user).find(params[:id])

    respond_to do |format|
      format.turbo_stream
    end
  end

  def has_required_roles? = current_user.has_roles?(:admin)
end
