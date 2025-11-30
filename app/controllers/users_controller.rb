class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, flash: { success: "Account created successfully." }
    else
      flash.now[:error] = "Failed to create account." # rubocop:disable Rails/I18nLocaleTexts
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.expect(user: %i[username password password_confirmation])
  end

  def has_required_roles?
    true
  end
end
