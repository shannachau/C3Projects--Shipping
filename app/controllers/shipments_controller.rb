class ShipmentsController < ApplicationController

  skip_before_filter :verify_authenticity_token, only: :ship

  def ship
    @shipping_data = JSON.parse(request.body.read)
    ups_response = ups_login.find_rates(origin, destination, package(@shipping_data[:weight]))
    usps_response = usps_login.find_rates(origin, destination, package(@shipping_data[:weight]))
    response = { ups: ups_response, usps: usps_response }
    render json: response.as_json
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
