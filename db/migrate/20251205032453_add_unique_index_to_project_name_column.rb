class AddUniqueIndexToProjectNameColumn < ActiveRecord::Migration[8.1]
  def change
    add_index :projects, :name, unique: true
  end
end
