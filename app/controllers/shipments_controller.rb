class ShipmentsController < ApplicationController

  skip_before_filter :verify_authenticity_token, only: :ship

  def ship
    @shipping_data = JSON.parse(request.body.read)

    ups_response = response_data(ups_login)
    usps_response = response_data(usps_login, true)

    response = { ups: ups_response, usps: usps_response }
    render json: response.as_json
  end

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

    response = response.sort_by(&:price).collect { |rate| { service: rate.service_name, delivery_date: rate.delivery_date, price_in_cents: rate.price } }
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
