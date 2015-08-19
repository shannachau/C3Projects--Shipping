require 'rails_helper'
require 'support/vcr_setup'

RSpec.describe UspsShipmentsController, type: :controller do
  describe "GET #estimate" do
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
        expect(@response.length).to be >= 6
      end

      it "each element is an Array of shipping info" do
        expect(@response.first).to be_an_instance_of Array
        expect(@response.first.length).to eq 2
      end

      it "shipping_info[0] is a string" do
        expect(@response.first[0]).to be_an_instance_of String
      end

      it "shipping_info[1] is an integer" do
        expect(@response.first[1]).to be_an_instance_of Fixnum
      end
    end
  end
end
