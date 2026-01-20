class AddDatetimeToLogEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :log_entries, :datetime, :datetime
  end
end
