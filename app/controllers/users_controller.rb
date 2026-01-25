class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.includes(:user_roles, log_entries: { subproject: :project }).find(params[:id])
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    @user = User.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @user = User.new(user_params.except(:roles))

    if @user.save
      @user.roles = user_params[:roles]
      redirect_to users_path, flash: { success: t(".success") }
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params.except(:roles))
      @user.roles = user_params[:roles]
      redirect_to users_path, flash: { success: t(".success") }
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    return redirect_to(users_path, flash: { error: t(".self_deletion") }) if current_user.id == params[:id].to_i

    @user = User.find(params[:id])
    if @user.destroy
      redirect_to users_path, flash: { success: t(".success") }
    else
      redirect_to users_path, flash: { error: @user.errors.full_messages.to_sentence }
    end
  end

  private

  def has_required_roles? = current_user.has_roles?(:admin)

  def user_params
    params.expect(user: [:username, :password, :password_confirmation, { roles: [] }])
  end
end
