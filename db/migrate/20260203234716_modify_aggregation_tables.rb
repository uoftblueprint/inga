class ModifyAggregationTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :snapshots

    remove_column :reports, :expiry, :date

    remove_reference :reports, :project, foreign_key: true

    create_table :journal_reports do |t|
      t.references :journal, null: false, foreign_key: true, index: true
      t.references :report, null: false, foreign_key: true, index: true
      t.index [:journal_id, :report_id], unique: true

      t.timestamps
    end

    create_table :aggregated_data do |t|
      t.string :type
      t.float :value
      t.string :additional_text
      t.references :report, null: false, foreign_key: true, index: true
      t.timestamps
    end
  end
end
