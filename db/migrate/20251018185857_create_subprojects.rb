class CreateSubprojects < ActiveRecord::Migration[8.0]
  def change
    create_table :subprojects do |t|
      t.string :name
      t.text :description
      t.string :address
      t.references :region, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
