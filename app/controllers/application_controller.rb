class ApplicationController < ActionController::Base
  include ApplicationHelper

  default_form_builder DefaultFormBuilder
  allow_browser versions: :modern
  helper_method :show_sidebar?
  before_action :require_login
  before_action :check_required_roles
  before_action :set_locale

  private

  def set_locale
    requested_locale = params[:locale]&.to_sym
    I18n.locale = if requested_locale && I18n.available_locales.include?(requested_locale)
                    requested_locale
                  else
                    I18n.default_locale
                  end
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def require_login
    redirect_to login_path, flash: { error: "You must be logged in to access this page" } unless logged_in?
  end

  def check_required_roles
    return if has_required_roles?

    target_path = unauthorized_redirect_path

    # Prevent redirect loops when the fallback destination is also unauthorized.
    if request.path == target_path
      render plain: "You do not have permission to access this page", status: :forbidden
      return
    end

    redirect_to target_path, flash: { error: "You do not have permission to access this page" }
  end

  def unauthorized_redirect_path
    return projects_path if current_user&.has_roles?(:admin)
    return reporter_dashboard_path if current_user&.has_roles?(:reporter)

    root_path
  end

  def show_sidebar? = true

  # All controllers must override this method
  def has_required_roles? = false
end
