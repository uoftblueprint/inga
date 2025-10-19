class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :login, :create ]
  def login; end

  def create
    user = User.find_by(username: params[:username])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, flash: { success: "Logged in successfully." }
    else
      redirect_to login_path, flash: { error: "Invalid username or password." }
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, flash: { success: "Logged out successfully." }
  end
end
