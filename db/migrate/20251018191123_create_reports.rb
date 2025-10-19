class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.date :start_date
      t.date :end_date
      t.date :expiry
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
