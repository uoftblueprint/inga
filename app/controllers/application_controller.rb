class ApplicationController < ActionController::Base
  include ApplicationHelper

  default_form_builder DefaultFormBuilder
  allow_browser versions: :modern
  helper_method :show_sidebar?, :admin?, :reporter?, :analyst?
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
    return if logged_in?

    redirect_to login_path, flash: { error: t("application_controller.require_login.error") }
  end

  def check_required_roles
    return if has_required_roles?

    redirect_with_authorization_error
  end

  def redirect_with_authorization_error
    clear_invalid_session if logged_in? && no_roles?

    redirect_to authorization_redirect_path, flash: { error: t("application_controller.check_required_roles.error") }
  end

  def unauthorized_redirect_path
    return projects_path if admin?
    return root_path if reporter?
    return reports_path if analyst?

    root_path
  end

  def authorization_redirect_path
    return login_path unless logged_in?

    target_path = unauthorized_redirect_path
    target_fullpath = begin
      uri = URI.parse(target_path)
      uri.query.present? ? "#{uri.path}?#{uri.query}" : uri.path
    rescue URI::InvalidURIError
      target_path
    end

    return login_path if request.fullpath == target_fullpath

    target_path
  end

  def clear_invalid_session
    session.delete(:user_id)
    @current_user = nil
  end

  def no_roles?
    !admin? && !reporter? && !analyst?
  end

  def admin?
    current_user&.has_roles?(:admin)
  end

  def reporter?
    current_user&.has_roles?(:reporter)
  end

  def analyst?
    current_user&.has_roles?(:analyst)
  end

  def show_sidebar? = true

  # All controllers must override this method
  def has_required_roles? = false
end
