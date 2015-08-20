class CreateAuditLogs < ActiveRecord::Migration
  def change
    create_table :audit_logs do |t|
      t.string :carrier, null:false
      t.string :delivery_service, null: false
      t.decimal :shipping_cost, null: false
      t.decimal :order_total, null: false
      t.integer :order_id, null: false
      t.timestamps null: false
    end
  end
end
