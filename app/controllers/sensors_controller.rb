class SensorsController < ApplicationController
  before_action :set_sensor, only: %i[ show update destroy ]
  skip_before_action :authorized, only: %i[ create ]
  before_action :require_authorization, except: %i[ create ]

  # GET /sensors
  def index
    @sensors = Sensor.all

    render json: @sensors
  end

  # GET /sensors/1
  def show
    render json: @sensor
  end

  # POST /sensors
  def create
    @sensor = Sensor.new(sensor_params)

    if @sensor.save
      render json: @sensor, status: :created, location: @sensor
    else
      render json: @sensor.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sensors/1
  def update
    if @sensor.update(sensor_params)
      render json: @sensor
    else
      render json: @sensor.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sensors/1
  def destroy
    @sensor.destroy
  end

  def find_by_user_id
    @sensors = Sensor.where(user_id: params[:user_id])
    if @sensors
      render json: @sensors
    else
      render json: { error: "Sensor not found" }, status: :not_found
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sensor
      @sensor = Sensor.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sensor_params
      params.require(:sensor).permit(:sensor_id, :user_id)
    end
end
