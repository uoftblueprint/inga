class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      create_user_roles
      # TODO: This should redirect to the Show page of that user
      redirect_to root_path, flash: { success: t(".success") }
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
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
