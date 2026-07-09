require 'rails_helper'

RSpec.describe "Diagnoses", type: :request do
  describe "POST /diagnoses" do
    it "returns ai diagnosis" do
      diagnosis = double()
      allow(diagnosis).to receive(:content).and_return("good impression")
      allow(Llm::DiagnoseImpression).to receive(:call).and_return(diagnosis)
      post "/diagnoses", params: { photos: [] }
      expect(response.status).to eq 200
      hash = JSON.parse(response.body)
      expect(hash["content"]).to eq "good impression"
    end

    it "returns 500 and user message when api failed" do
      allow(Llm::DiagnoseImpression).to receive(:call).and_raise(RubyLLM::ServerError)
      post "/diagnoses", params: { photos: [] }
      hash = JSON.parse(response.body)
      expect(response.status).to eq 500
      expect(hash["message"]).to eq "AI回答の取得に失敗しました"
    end
  end
end
