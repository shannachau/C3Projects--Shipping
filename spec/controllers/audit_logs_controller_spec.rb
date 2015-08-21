require 'rails_helper'

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


    end
    context "invalid request" do
    end


    end
  end
end
