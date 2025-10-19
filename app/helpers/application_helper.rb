module ApplicationHelper
  def logged_in? = !!session[:user_id]

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if logged_in?
  end
end
