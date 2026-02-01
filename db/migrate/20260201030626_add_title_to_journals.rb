class AddTitleToJournals < ActiveRecord::Migration[8.1]
  def change
    add_column :journals, :title, :string, null: false
  end
end
