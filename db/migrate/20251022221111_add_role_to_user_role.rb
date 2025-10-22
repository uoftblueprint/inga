class AddRoleToUserRole < ActiveRecord::Migration[8.0]
  def change
    add_column :user_roles, :role, :string, null: false
  end
end
