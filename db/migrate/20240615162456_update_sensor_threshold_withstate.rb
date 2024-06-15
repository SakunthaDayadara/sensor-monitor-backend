class UpdateSensorThresholdWithstate < ActiveRecord::Migration[7.0]
  def change
    add_column :sensor_thresholds, :state, :string, default: "active"
  end
end
