require 'rails_helper'

RSpec.describe UspsShipmentsController, type: :controller do
  describe "GET #estimate" do
    it "is successful" do
      get :estimate
      expect(response.response_code).to eq 200
    end

    it "returns json" do
      get :estimate
      expect(response.header['Content-Type']).to include 'application/json'
    end
  end
end
