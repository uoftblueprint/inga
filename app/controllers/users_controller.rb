class UsersController < ApplicationController
  def index
    @users = User.all

    if params[:username].present?
      @users = @users.where("username LIKE ?", "%#{params[:username]}%")
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      # TODO: This should redirect to the Show page of that user
      redirect_to root_path, flash: { success: t(".success") }
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, flash: { success: "User deleted successfully." }
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, flash: { success: t(".success") }
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: %i[username password password_confirmation])
  end

  def create_user_roles
    return unless params[:user]&.key?(:roles)

    roles = params[:user][:roles] || []
    roles.each do |role|
      @user.user_roles.create!(role: role) if role.present?
    end
  end

  def has_required_roles?
    case action_name
    when "new", "create"
      current_user.has_roles?(:admin)
    else
      true
    end
  end
end
