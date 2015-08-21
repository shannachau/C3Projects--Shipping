class ShipmentsController < ApplicationController

  skip_before_filter :verify_authenticity_token, only: :ship

  def index
    render json: { errors: "This page does not exist. Perhaps you were looking for 'adaships.herokuapp.com/log' or 'adaships.herokuapp.com/ship'."}, status: 404
  end

  def ship
    @shipping_data = JSON.parse(request.body.read)
    if  @shipping_data.keys.length != 5 ||
        @shipping_data.values.select(&:nil?).length != 0 ||
        @shipping_data.values.select(&:empty?).any?
      render json: { errors: "Incomplete request."}, status: :bad_request
    else
      ups_response = response_data(ups_login)
      usps_response = response_data(usps_login, true)

      response = { ups: ups_response, usps: usps_response }
      render json: response.as_json
    end
  end

  private

  def response_data(login_method, usps = false)
    response = login_method.find_rates(origin, destination, package(@shipping_data[:weight]))

    if usps
      response = response.rates.select { |rate|
        rate.service_code == "1" ||
        rate.service_code == "3" ||
        rate.service_code == "4" ||
        rate.service_code == "22"
      }
    else
      response = response.rates
    end

    response = response.sort_by(&:price).collect { |rate| { carrier: rate.carrier, delivery: rate.service_name, delivery_date: rate.delivery_date, shipping_cost: (rate.price.to_f / 100) } }
    response.each do |rate|
      rate[:delivery_date] ||= "No delivery estimate available."
    end
  end

  def destination
    ActiveShipping::Location.new(
      address1: @shipping_data["address"],
      city: @shipping_data["city"],
      state: @shipping_data["state"],
      zip: @shipping_data["zip"],
      country: @shipping_data["country"]
      )
  end
end
