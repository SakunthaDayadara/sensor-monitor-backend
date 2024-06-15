class SensorThreshold < ApplicationRecord
  belongs_to :sensor, foreign_key: 'sensor_id'

  before_create :set_default_threshold_value

  def set_default_threshold_value
    self.threshold_value = 30
  end


end
