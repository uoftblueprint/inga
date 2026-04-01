class LogEntriesController < ApplicationController
  def new
    @projects = Project.all
  end

  def has_required_roles? = reporter?
end
