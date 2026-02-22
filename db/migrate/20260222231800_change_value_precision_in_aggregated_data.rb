class ChangeValuePrecisionInAggregatedData < ActiveRecord::Migration[8.1]
  def change
    change_column :aggregated_data, :value, :decimal, precision: 10, scale: 2
  end
end
