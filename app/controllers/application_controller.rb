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

  def show_sidebar? = true

  # All controllers must override this method
  def has_required_roles? = false
end
