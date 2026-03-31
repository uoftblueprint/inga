class HomeController < ApplicationController
  def index
    if current_user.has_roles?(:admin)
      redirect_to projects_path
      return
    end

    if current_user.has_roles?(:reporter)
      redirect_to reporter_dashboard_path
      return
    end

    render plain: "You do not have permission to access this page", status: :forbidden
  end

  private

  def has_required_roles? = true
end
