require 'httparty'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  ORIGIN = { country: 'US', state: 'WA', city: 'Seattle', zip: '98101' }

  private

  def origin
    ActiveShipping::Location.new(ORIGIN)
  end

  def estimate_destination
    ActiveShipping::Location.new(zip: params[:zip], country: 'US')
  end

  # def estimate_package
  #   weight = params[:weight].to_i
  #   if weight <= 10
  #     dimensions = [ 12, 10, 8 ]
  #   elsif weight > 10 && weight <= 20
  #     dimensions = [ 12, 12, 5.5 ]
  #   else
  #     dimensions = [ 14, 11, 11 ]
  #   end
  #   ActiveShipping::Package.new(weight, dimensions, units: :imperial)
  # end

  def package(weight)
    weight = weight.to_i
    # weight = @shipping_data[:weight].to_i
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
