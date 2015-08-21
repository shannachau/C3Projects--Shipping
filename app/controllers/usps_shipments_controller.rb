class UspsShipmentsController < ApplicationController

  def estimate
    if (/\A\d+\z/.match(params[:weight])).nil? || (/\A\d+\z/.match(params[:zip])).nil?
      render json: { errors: "Please enter a numeric value for weight and zip code."}, status: :bad_request
    elsif params[:weight].to_i > 1120
      render json: { errors: "USPS does not support weights above 70lbs/1120oz."} , status: :bad_request
    elsif params[:zip].length != 5
      render json: { errors: "Zip code needs to be five digits." }, status: :bad_request
    else
      response = usps_login.find_rates(origin, estimate_destination, package(params[:weight]))
      # Select only service codes relevant to Petsy packages
      response = response.rates.select { |rate|
        rate.service_code == "1" ||
        rate.service_code == "3" ||
        rate.service_code == "4" ||
        rate.service_code == "22"
      }

      usps_rates = response.sort_by(&:price).collect { |rate| { delivery: rate.service_name, shipping_cost: (rate.price.to_f / 100) } }
      render json: usps_rates.as_json
    end
  end

end
