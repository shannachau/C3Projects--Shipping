require 'httparty'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  ORIGIN = { country: 'US', state: 'WA', city: 'Seattle', zip: '98101' }

  skip_before_filter :verify_authenticity_token, only: :ship

  def ship
    @shipping_data = JSON.parse(request.body.read)
    # body will include address, city, state, zipcode, country; also weight, dimensions
    ups_response = ups_login.find_rates(origin, destination, package)
    usps_response = usps_login.find_rates(origin, destination, package)
    response = { ups: ups_response, usps: usps_response }
    render json: response.as_json
  end

  private

  def origin
    ActiveShipping::Location.new(ORIGIN)
  end

  def estimate_destination
    ActiveShipping::Location.new(zip: params[:zip], country: 'US')
  end

  def destination
    ActiveShipping::Location.new(
      city: @shipping_data["city"],
      state: @shipping_data["state"],
      zip: @shipping_data["zip"],
      country: @shipping_data["country"]
      )
  end

  def estimate_package
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

  def package
    weight = @shipping_data[:weight].to_i
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
  
  def ups_login
    ActiveShipping::UPS.new(login: ENV['UPS_LOGIN'], password: ENV['UPS_PASSWORD'], key: ENV['UPS_KEY'], origin_name: 'petsy', origin_account: ENV['UPS_ACCOUNT_NO'])
  end
end
