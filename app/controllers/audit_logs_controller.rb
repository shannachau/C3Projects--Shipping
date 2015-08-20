class AuditLogsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :log

  def log
    params[:log_params] = JSON.parse(request.body.read)
    log = AuditLog.new(create_params(params[:log_params]))

    if log.save
      render json: { success: "Shipment information logged." }, status: 201
    else
      render json: { error: "Shipment information was not logged."}, status: :bad_request
    end
  end

  private

  def create_params(params)
    params.permit("carrier", "delivery_service", "shipping_cost", "order_total", "order_id")
  end
end
