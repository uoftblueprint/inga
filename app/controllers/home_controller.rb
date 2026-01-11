class HomeController < ApplicationController
  attr_reader :projects

  def index
    @projects = Project.active.includes(subprojects: :region)
  end

  private

  def has_required_roles? = true
end
