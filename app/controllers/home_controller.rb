class HomeController < ApplicationController
  def index
    if admin?
      redirect_to projects_path
      return
    end

    if reporter?
      render "reporter_dashboards/show"
      return
    end

    if analyst?
      redirect_to reports_path
      return
    end

    redirect_with_authorization_error
  end

  private

  def has_required_roles? = true
end
