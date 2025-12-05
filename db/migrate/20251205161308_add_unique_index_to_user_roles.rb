class AddUniqueIndexToUserRoles < ActiveRecord::Migration[8.1]
  def change
    add_index :user_roles, [:user_id, :role], unique: true
  end
end
