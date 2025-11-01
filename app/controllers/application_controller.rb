class ApplicationController < ActionController::Base
  include ApplicationHelper

  allow_browser versions: :modern
  before_action :require_login
  before_action :check_required_roles

  private

  def require_login
    redirect_to login_path, flash: { error: "You must be logged in to access this page" } unless logged_in?
  end

  def check_required_roles
    redirect_to root_path, flash: { error: "You do not have permission to access this page" } unless has_required_roles?
  end

  # All controllers must override this method
  def has_required_roles? = false
end
