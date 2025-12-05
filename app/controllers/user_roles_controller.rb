class UserRolesController < ApplicationController
  def create
    @user = User.find(params[:user_id])
    @user_role = @user.user_roles.build(user_role_params)

    if @user_role.save
      redirect_to root_path, flash: { success: "Role added successfully." }
    else
      redirect_to root_path, flash: { error: @user_role.errors.full_messages.to_sentence }
    end
  rescue ArgumentError => e
    redirect_to root_path, flash: { error: e.message }
  end

  private

  def user_role_params
    params.expect(user_role: [:role])
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
