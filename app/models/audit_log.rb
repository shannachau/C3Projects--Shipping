class AuditLog < ActiveRecord::Base
  # Validations
  validates :carrier, :delivery_service, :shipping_cost, :order_total, :order_id, presence: true
  validates :order_id, uniqueness: true
  validates :shipping_cost, :order_total, :order_id, numericality: true
end
