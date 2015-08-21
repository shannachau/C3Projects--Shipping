require 'rails_helper'

RSpec.describe AuditLog, type: :model do
  describe "model validations" do
    required_vars = [ :carrier, :delivery_service, :shipping_cost, :order_total, :order_id]
    required_vars.each do |var|
      it "AuditLog must include a #{var}" do
        log = build :audit_log, var => nil
        expect(log).to_not be_valid
        expect(log.errors.keys).to include(var)
        expect(AuditLog.count).to eq(0)
      end
    end

    it "order_id must be unique" do
      create :audit_log
      log = build :audit_log
      expect(log).to_not be_valid
      expect(AuditLog.count).to eq(1)
    end

    numerical_vars = [ :shipping_cost, :order_total, :order_id ]
    numerical_vars.each do |var|
      it "#{var} must be a number" do
        log = build :audit_log, var => "ima string"
        expect(log).to_not be_valid
        expect(log.errors.keys).to include(var)
        expect(AuditLog.count).to eq(0)
      end
    end
  end
end
