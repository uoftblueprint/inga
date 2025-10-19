class CreateRegions < ActiveRecord::Migration[8.0]
  def change
    create_table :regions do |t|
      t.string :name
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
    end
  end
end
