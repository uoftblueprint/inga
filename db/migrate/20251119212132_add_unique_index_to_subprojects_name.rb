class AddUniqueIndexToSubprojectsName < ActiveRecord::Migration[8.0]
  def change
    add_index :subprojects, [:project_id, :name], unique: true
  end
end
