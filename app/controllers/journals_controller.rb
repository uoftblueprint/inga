class JournalsController < ApplicationController
  def new
    @projects = Project.all
  end

  def form_card
    @journal = Journal.find(params[:id])
    render partial: "form_card"
  end

  def has_required_roles? = current_user.has_roles?(:admin)
end
