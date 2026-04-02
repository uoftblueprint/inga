module ApplicationHelper
  def logged_in? = !!session[:user_id]

  def current_user
    User.find_by(id: session[:user_id]) if logged_in?
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
end
