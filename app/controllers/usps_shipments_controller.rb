class UspsShipmentsController < ApplicationController
  #TODO: Max weight for package is 70. Remember to handle for this

  def estimate
    response = usps_login.find_rates(origin, estimate_destination, package)
    usps_rates = response.rates.sort_by(&:price).collect {|rate| [rate.service_name, rate.price]}

    render json: usps_rates.as_json
  end

  private

  def usps_login
    ActiveShipping::USPS.new(login: ENV['USPS_USERNAME'])
  end
end
