class UpsShipmentsController < ApplicationController

  def estimate
    if (/\A\d+\z/.match(params[:weight])).nil? || (/\A\d+\z/.match(params[:zip])).nil?
      render json: { error: "Please enter a numeric value for weight and zip code."}, status: :bad_request
    elsif params[:weight].to_i > 2400
      render json: { error: "UPS does not support weights above 150lbs/2400oz." }, status: :bad_request
    elsif params[:zip].length != 5
      render json: { error: "Zip code needs to be five digits." }, status: :bad_request
    else
      response = ups_login.find_rates(origin, estimate_destination, package)
      ups_rates = response.rates.sort_by(&:price).collect {|rate| [rate.service_name, rate.price]}

      render json: ups_rates.as_json
    end

  end


  def ship
    # placeholder for now for testing
    shipping_data = request.body.read
    render json: shipping_data.as_json
  end

  private

  def ups_login
    ActiveShipping::UPS.new(login: ENV['UPS_LOGIN'], password: ENV['UPS_PASSWORD'], key: ENV['UPS_KEY'], origin_name: 'petsy', origin_account: ENV['UPS_ACCOUNT_NO'])
  end
end
