require 'rails_helper'

RSpec.describe UspsShipmentsController, type: :controller do
  describe "GET #estimate" do
    it "is successful" do
      get :estimate, zip: 91803, weight: 15
      expect(response.response_code).to eq 200
    end

    it "returns json" do
      get :estimate, zip: 91803, weight: 15
      expect(response.header['Content-Type']).to include 'application/json'
    end
  end

    context "the returned json object" do
      before :each do
        get :estimate, zip: 91803, weight: 15
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
