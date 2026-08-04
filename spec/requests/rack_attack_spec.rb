require 'rails_helper'

RSpec.describe "RackAttach", type: :request do
  describe "POST /diagnoses" do
    it "not returns 429 within throttle limit" do
      Rack::Attack.reset!
      60.times { post "/diagnoses", params: { photos: [] } }
      expect(response.status).not_to eq 429
    end

    it "returns 429 over throttle limit" do
      Rack::Attack.reset!
      61.times { post "/diagnoses", params: { photos: [] } }
      expect(response.status).to eq 429
    end
  end
end
