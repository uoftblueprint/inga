class AddUniqueIndexToRegionsName < ActiveRecord::Migration[8.1]
  def change
      add_index :regions, :name, unique: true
  end
end
