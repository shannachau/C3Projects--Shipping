require 'rails_helper'
require 'support/vcr_setup'

RSpec.describe AuditLogsController, type: :controller do
  describe "POST #log" do
    context "valid request" do
      before :each do
        VCR.use_cassette "audit_log" do
          post :log, { carrier: "ups",
                        delivery_service: "Super Fast",
                        shipping_cost: "25.95",
                        order_total: "80.75",
                        order_id: "10"
                      }.to_json,
                      { format: :json }

        end
      end

      it "is successful" do
        expect(response.response_code).to eq 201
      end

      it "returns json" do
        expect(response.header['Content-Type']).to include 'application/json'
      end

      it "creates an AuditLog object" do
        expect(AuditLog.count).to eq 1
        expect(AuditLog.first.delivery_service).to eq "Super Fast"
      end
    end

    context "invalid request" do
      before :each do
        VCR.use_cassette "audit_log" do
          post :log, { carrier: "ups",
                        delivery_service: "Super Fast",
                        shipping_cost: "25.95",
                        order_id: "10"
                      }.to_json,
                      { format: :json }
        end
      end

      it "is not successful" do
        expect(response.response_code).to eq 400
      end

      it "returns json containing an error" do
        expect(response.header['Content-Type']).to include 'application/json'
        expect(eval(response.body)[:error]).to eq "Shipment information was not logged."
      end

      it "does not persist an AuditLog object" do
        expect(AuditLog.count).to eq 0
      end
    end
  end
end
