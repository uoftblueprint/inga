class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[login create]
  def login; end

  def create
    user = User.find_by(username: params[:username])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, flash: { success: t(".success") }
    else
      redirect_to login_path, flash: { error: t(".error") }
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, flash: { success: t(".success") }
  end

  private

  def has_required_roles? = true
end
