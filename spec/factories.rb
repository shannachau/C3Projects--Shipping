FactoryGirl.define do
  factory :audit_log do
    carrier "ups"
    delivery_service "Super extra fast"
    shipping_cost "18.96"
    order_total "89.40"
    order_id 1
  end
end
