class UpsShipmentsController < ApplicationController

  def estimate
    if (/\A\d+\z/.match(params[:weight])).nil? || (/\A\d+\z/.match(params[:zip])).nil?
      render json: { errors: "Please enter a numeric value for weight and zip code."}, status: :bad_request
    elsif params[:weight].to_i > 2400
      render json: { errors: "UPS does not support weights above 150lbs/2400oz." }, status: :bad_request
    elsif params[:zip].length != 5
      render json: { errors: "Zip code needs to be five digits." }, status: :bad_request
    else
      response = ups_login.find_rates(origin, estimate_destination, package(params[:weight]))
      ups_rates = response.rates.sort_by(&:price).collect {|rate| [rate.service_name, rate.price]}

      render json: ups_rates.as_json
    end

  end

end
