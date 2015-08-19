class UpsShipmentsController < ApplicationController
  def estimate
    response = ups_login.find_rates(origin, estimate_destination, package)
    ups_rates = response.rates.sort_by(&:price).collect {|rate| [rate.service_name, rate.price]}

    render json: ups_rates.as_json
  end

  private

  def ups_login
    ActiveShipping::UPS.new(login: ENV['UPS_LOGIN'], password: ENV['UPS_PASSWORD'], key: ENV['UPS_KEY'], origin_name: 'petsy', origin_account: ENV['UPS_ACCOUNT_NO'])
  end
end
