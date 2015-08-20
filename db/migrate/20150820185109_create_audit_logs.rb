class CreateAuditLogs < ActiveRecord::Migration
  def change
    create_table :audit_logs do |t|
      t.string :carrier
      t.string :delivery_service
      t.decimal :shipping_cost
      t.decimal :order_total
      t.integer :order_id
      t.timestamps null: false
    end
  end
end
