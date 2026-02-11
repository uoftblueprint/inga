class ApplicationController < ActionController::Base
  include ApplicationHelper

  default_form_builder DefaultFormBuilder
  allow_browser versions: :modern
  before_action :require_login
  before_action :check_required_roles
  before_action :set_locale

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def require_login
    redirect_to login_path, flash: { error: "You must be logged in to access this page" } unless logged_in?
  end

  def check_required_roles
    redirect_to root_path, flash: { error: "You do not have permission to access this page" } unless has_required_roles?
  end

  # All controllers must override this method
  def has_required_roles? = false
end
