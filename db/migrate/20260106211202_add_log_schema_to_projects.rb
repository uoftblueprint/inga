class AddLogSchemaToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :log_schema, :text, null: false, default: '{}'
  end
end
