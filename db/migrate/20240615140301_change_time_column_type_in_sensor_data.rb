class ChangeTimeColumnTypeInSensorData < ActiveRecord::Migration[7.0]
  def up
    change_column :sensor_data, :time_column, :string
  end

  def down
    change_column :sensor_data, :time_column, :time
  end
end
