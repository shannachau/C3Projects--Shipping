require 'rails_helper'
require 'support/vcr_setup'

RSpec.describe ShipmentsController, type: :controller do
  describe "GET #index" do
    it "responds with an error and status code 404" do
      get :index
      expect(response.response_code).to eq 404
      expect(eval(response.body)[:errors]).to include("This page does not exist. Perhaps you were looking for 'adaships.herokuapp.com/log' or 'adaships.herokuapp.com/ship'.")
    end
  end

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


    context "invalid request" do
      it "returns code 400 and error message when an element is missing from the body" do
        VCR.use_cassette "ship_response" do
          post :ship, { address1: "123 Fake St",
                      city:    "Fake City",
                      zip:     "98155",
                      country: "US"}.to_json,
                      { format: :json }
        end
        expect(response.response_code).to eq 400
        expect(eval(response.body)[:errors]).to include("Incomplete request.")
      end

      it "returns code 400 and error message when an element in the body is empty" do
        VCR.use_cassette "ship_response" do
          post :ship, { address1: "",
                      city:    "Fake City",
                      state:   "WA",
                      zip:     "98155",
                      country: "US"}.to_json,
                      { format: :json }
        end
        expect(response.response_code).to eq 400
        expect(eval(response.body)[:errors]).to include("Incomplete request.")
      end

      it "returns code 400 and error message when an element in the body is nil" do
        VCR.use_cassette "ship_response" do
          post :ship, { address1: nil,
                      city:    "Fake City",
                      state:   "WA",
                      zip:     "98155",
                      country: "US"}.to_json,
                      { format: :json }
        end
        expect(response.response_code).to eq 400
        expect(eval(response.body)[:errors]).to include("Incomplete request.")
      end
    end

    context "Timeout error" do
      before :each do
        stub_const("ShipmentsController::TIMEOUT", 0.00000000000000000001)
        VCR.use_cassette "timeout_ship_response" do
          post :ship, { address1: "123 Fake St",
              city:    "Fake City",
              state:   "WA",
              zip:     "98155",
              country: "US"}.to_json,
            { format: :json }
        end
      end

      it "responds with status code 408" do
        expect(response.response_code).to eq 408
      end

      it "responds with appropriate error message" do
        expect(eval(response.body)[:errors]).to include "Request timed out."
      end
    end
  end
end
