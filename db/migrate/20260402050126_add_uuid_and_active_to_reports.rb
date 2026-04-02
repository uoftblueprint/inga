class AddUuidAndActiveToReports < ActiveRecord::Migration[8.1]
  class MigrationReport < ApplicationRecord
    self.table_name = "reports"
  end

  def up
    add_column :reports, :uuid, :string
    add_column :reports, :active, :boolean, default: true, null: false

    MigrationReport.reset_column_information
    MigrationReport.find_each do |report|
      report.update_columns(uuid: SecureRandom.uuid)
    end

    change_column_null :reports, :uuid, false
    add_index :reports, :uuid, unique: true
  end

  def down
    remove_index :reports, :uuid
    remove_column :reports, :uuid
    remove_column :reports, :active
  end
end
