class UspsShipmentsController < ApplicationController

  def estimate
    if (/\A\d+\z/.match(params[:weight])).nil? || (/\A\d+\z/.match(params[:zip])).nil?
      render json: { error: "Please enter a numeric value for weight and zip code."}, status: :bad_request
    elsif params[:weight].to_i > 1120
      render json: { error: "USPS does not support weights above 70lbs/1120oz."} , status: :bad_request
    elsif params[:zip].length != 5
      render json: { error: "Zip code needs to be five digits." }, status: :bad_request
    else
      response = usps_login.find_rates(origin, estimate_destination, package(params[:weight]))
      usps_rates = response.rates.sort_by(&:price).collect {|rate| [rate.service_name, rate.price]}

      render json: usps_rates.as_json
    end
  end

end
