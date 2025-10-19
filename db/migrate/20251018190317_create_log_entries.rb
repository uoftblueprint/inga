class CreateLogEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :log_entries do |t|
      t.references :subproject, foreign_key: true
      t.references :user, foreign_key: true
      t.json :metadata

      t.timestamps
    end
  end
end
