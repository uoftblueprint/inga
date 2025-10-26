class ApplicationController < ActionController::Base
  include ApplicationHelper

  allow_browser versions: :modern
  before_action :require_login

  def require_login
    redirect_to login_path, flash: {error: "You must be logged in to access this page"} unless logged_in?
  end
end
