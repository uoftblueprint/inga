class JournalsController < ApplicationController
  def new
    @projects = Project.all
  end

  def has_required_roles? = current_user.has_roles?(:admin)
end
