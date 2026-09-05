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

    describe "global daily limit" do
      before do
        stub_const("Rack::Attack::DIAGNOSES_DAILY_LIMIT", 2)
      end

      it "not returns 429 within daily limit" do
        2.times { |i| post "/diagnoses", params: { photos: [] }, headers: { "REMOTE_ADDR" => "1.2.3.#{i}" } }
        expect(response.status).not_to eq 429
      end

      it "returns 429 over daily limit" do
        3.times { |i| post "/diagnoses", params: { photos: [] }, headers: { "REMOTE_ADDR" => "1.2.3.#{i}" } }
        expect(response.status).to eq 429
      end
    end
  end
end
