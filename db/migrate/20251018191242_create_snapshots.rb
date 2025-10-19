class CreateSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :snapshots do |t|
      t.references :report, foreign_key: true
      t.json :aggregated_data
      t.timestamps
    end
  end
end
