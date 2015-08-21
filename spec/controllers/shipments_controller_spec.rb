require 'rails_helper'
require 'support/vcr_setup'

RSpec.describe ShipmentsController, type: :controller do
  describe "POST #ship" do
    context "valid request" do
      before :each do
        VCR.use_cassette 'ship_response' do
          post :ship, { address1: "123 Fake St",
                        city:    "Fake City",
                        state:   "WA",
                        zip:     "98155",
                        country: "US"}.to_json,
                      { format: :json }
        end
      end

      it "is successful" do
        expect(response.response_code).to eq 200
      end

      it "returns json" do
        expect(response.header['Content-Type']).to include 'application/json'
      end

      context "the returned json object" do
        before :each do
          @response = JSON.parse response.body
        end

        it "is a hash of shipping information" do
          expect(@response).to be_an_instance_of Hash
          expect(@response.length).to eq 2
        end

        it "includes UPS and USPS keys" do
          expect(@response.keys).to eq(["ups", "usps"])
        end
      end
    end


    # context "invalid request" do
    #   before :each do
    #     VCR.use_cassette 'invalid_ship_response' do
    #       post :ship, { address1: "123 Fake St",
    #                     city:    "Fake City",
    #                     state:   "",
    #                     zip:     "",
    #                     country: "US"}.to_json,
    #                   { format: :json }
    #     end
    #   end
    #
    #   it "is successful" do
    #     expect(response.response_code).to eq 200
    #   end
    # end
  end
end
