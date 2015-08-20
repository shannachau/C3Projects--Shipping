require 'rails_helper'
require 'support/vcr_setup'

RSpec.describe UspsShipmentsController, type: :controller do
  describe "GET #estimate" do
    context "valid request" do
      before :each do
        VCR.use_cassette 'USPS_response' do
          get :estimate, zip: 91803, weight: 15
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

        it "is an array of shipping information" do
          expect(@response).to be_an_instance_of Array
          expect(@response.length).to be >= 4
        end

        it "each element is a hash of shipping info" do
          expect(@response.first).to be_an_instance_of Hash
          expect(@response.first.length).to eq 2
        end

        it "shipping_info hash includes delivery and shipping cost keys" do
          expect(@response.first.keys).to eq(["delivery", "shipping_cost"])
        end

        it "shipping_info['delivery'] is a string" do
          expect(@response.first['delivery']).to be_an_instance_of String
        end

        it "shipping_info['shipping_cost'] is a string" do
          expect(@response.first['shipping_cost']).to be_an_instance_of Fixnum
        end
      end
    end

    context "invalid request" do
      context "Non-numeric values for weight and/or zipcode" do
        it "returns status 400" do
          VCR.use_cassette 'USPS_response' do
            get :estimate, zip: "abcde", weight: "big"
          end
          expect(response.response_code).to eq 400
          expect(eval(response.body)[:errors]).to include("Please enter a numeric value for weight and zip code.")
        end
      end

      context "Weight exceeds 1120oz" do
        it "returns status 400" do
          VCR.use_cassette 'USPS_response' do
            get :estimate, zip: 98122, weight: 1121
          end
          expect(response.response_code).to eq 400
          expect(eval(response.body)[:errors]).to include("USPS does not support weights above 70lbs/1120oz.")
        end
      end

      context "Zipcode is not 5 characters in length" do
        it "returns status 400 when zipcode is too short" do
          VCR.use_cassette 'USPS_response' do
            get :estimate, zip: "1", weight: 16
          end
          expect(response.response_code).to eq 400
          expect(eval(response.body)[:errors]).to include("Zip code needs to be five digits.")
        end

        it "returns status 400 when zipcode is too long" do
          VCR.use_cassette 'USPS_response' do
            get :estimate, zip: "1111111111", weight: 16
          end
          expect(response.response_code).to eq 400
          expect(eval(response.body)[:errors]).to include("Zip code needs to be five digits.")
        end
      end
    end
  end
end
