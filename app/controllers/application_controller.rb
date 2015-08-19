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
end
