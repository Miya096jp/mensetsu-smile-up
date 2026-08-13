require 'rails_helper'

RSpec.describe "RackAttach", type: :request do
  describe "POST /diagnoses" do
    before do
      Rack::Attack.enabled = true
      Rack::Attack.reset!
    end

    it "not returns 429 within throttle limit" do
      3.times { post "/diagnoses", params: { photos: [] } }
      expect(response.status).not_to eq 429
    end

    it "returns 429 over throttle limit" do
      4.times { post "/diagnoses", params: { photos: [] } }
      expect(response.status).to eq 429
    end
  end
end
