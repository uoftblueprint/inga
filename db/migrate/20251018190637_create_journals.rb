class CreateJournals < ActiveRecord::Migration[8.0]
  def change
    create_table :journals do |t|
      t.references :subproject, foreign_key: true
      t.references :user, foreign_key: true
      t.text :markdown_content

      t.timestamps
    end
  end
end
