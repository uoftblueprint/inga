class HomeController < ApplicationController
  def index
    if admin?
      redirect_to projects_path
      return
    end

    if reporter?
      redirect_to reporter_dashboard_path
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
