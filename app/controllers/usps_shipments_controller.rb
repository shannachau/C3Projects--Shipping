class UspsShipmentsController < ApplicationController

  def estimate
    response = usps_login.find_rates(origin, destination, package)
    usps_rates = response.rates.sort_by(&:price).collect {|rate| [rate.service_name, rate.price]}

    render json: usps_rates.as_json
  end

  private

  def origin
    ActiveShipping::Location.new(ORIGIN)
  end

  def destination
    ActiveShipping::Location.new(postal_code: params[:zip], country: 'US')
  end

  def package
    weight = params[:weight].to_i
    if weight <= 10
      dimensions = [ 12, 10, 8 ]
    elsif weight > 10 && weight <= 20
      dimensions = [ 12, 12, 5.5 ]
    else
      dimensions = [ 14, 11, 11 ]
    end
    ActiveShipping::Package.new(weight, dimensions, units: :imperial)
  end

  def usps_login
    ActiveShipping::USPS.new(login: ENV['USPS_USERNAME'])
  end
end
