require 'rails_helper'

RSpec.describe "Diagnoses", type: :request do
  describe "POST /diagnoses" do
    it "returns ai diagnosis" do
      allow(Llm::DiagnoseImpression).to receive(:call).and_return("good impression")
      post "/diagnoses", params: { photos: [] }
      expect(response.body).to eq "good impression"
    end
  end
end
