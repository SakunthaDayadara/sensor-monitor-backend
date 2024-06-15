class SensorDataController < ApplicationController
  before_action :set_sensor_datum, only: %i[ show update destroy ]
  skip_before_action :authorized, only: %i[ create ]
  before_action :require_authorization, except: %i[ create ]

  # GET /sensor_data
  def index
    @sensor_data = SensorDatum.all

    render json: @sensor_data
  end

  # GET /sensor_data/1
  def show
    render json: @sensor_datum
  end

  # POST /sensor_data
  def create
    date_time = DateTime.parse(sensor_datum_params[:date_str])
    date_column = date_time.to_date
    time_column = date_time.strftime("%H:%M:%S")
    sensor_value = Sensor.find_by(sensor_id: sensor_datum_params[:sensor_id])

    @sensor_datum = SensorDatum.new(
      sensor_id: sensor_datum_params[:sensor_id],
      date_column: date_column,
      time_column: time_column,
      data_value: sensor_datum_params[:data_value]  # Corrected to use :data_value
    )

    if @sensor_datum.save
      @sensor_threshold = SensorThreshold.find_by(sensor_id: sensor_datum_params[:sensor_id])
      if @sensor_threshold && sensor_datum_params[:data_value].to_i > @sensor_threshold.threshold_value
        @sensor = Sensor.find_by(sensor_id: sensor_datum_params[:sensor_id])
        @user = User.find(@sensor.user_id)
        formatted_number = "+94" + @user.telephone[-9..-1]
        text = "Your sensor value has exceeded the threshold value. Please check the sensor."
        response = HTTParty.post("#{ENV['BACKEND_URL']}/send_sms",
                                 body: { to: formatted_number, text: text }, timeout: 20)
        if response.success?
          render json: @sensor_datum, status: :created, location: @sensor_datum
        else
          render json: { error: "Failed to send SMS" }, status: :unprocessable_entity
        end
      else
        render json: @sensor_datum, status: :created, location: @sensor_datum
      end
    else
      render json: @sensor_datum.errors, status: :unprocessable_entity
    end
  end


  # PATCH/PUT /sensor_data/1
  def update
    if @sensor_datum.update(sensor_datum_params)
      render json: @sensor_datum
    else
      render json: @sensor_datum.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sensor_data/1
  def destroy
    @sensor_datum.destroy
  end

  def find_by_sensor_id
    @sensor_data = SensorDatum.where(sensor_id: params[:sensor_id])
    if @sensor_data
      render json: @sensor_data
    else
      render json: { error: "Sensor data not found" }, status: :not_found
    end
  end

  def find_by_user_id
    @user = User.find_by(user_id: params[:user_id])
    if @user
      @sensors = Sensor.where(user_id: @user.id)
      @sensor_data = SensorDatum.where(sensor_id: @sensors.ids)
      if @sensor_data
        render json: @sensor_data
      else
        render json: { error: "Sensor data not found" }, status: :not_found
      end
    else
      render json: { error: "User not found" }, status: :not_found
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sensor_datum
      @sensor_datum = SensorDatum.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sensor_datum_params
      params.require(:sensor_datum).permit(:sensor_id, :date_column, :time_column, :data_value, :date_str)
    end
end
