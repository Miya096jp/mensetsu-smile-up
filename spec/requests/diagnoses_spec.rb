require 'rails_helper'

RSpec.describe "Diagnoses", type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  describe "POST /diagnoses" do
    let(:photos) { 2.times.map { file_fixture_upload('photo.jpg', 'image/jpeg') } }

    it "returns ai diagnosis" do
      diagnosis = double()
      allow(diagnosis).to receive(:content).and_return("good impression")
      allow(Llm::DiagnoseImpression).to receive(:call).and_return(diagnosis)
      post "/diagnoses", params: { photos: photos }
      expect(response.status).to eq 200
      hash = JSON.parse(response.body)
      expect(hash["content"]).to eq "good impression"
    end

    it "returns 422 with invalid params" do
      photos = [ file_fixture_upload('photo.jpg', 'image/jpeg') ]
      post "/diagnoses", params: { photos: photos }
      expect(response.status).to eq 422
    end

    it "returns 503 and user message when api failed" do
      allow(Llm::DiagnoseImpression).to receive(:call).and_raise(RubyLLM::ServerError)
      post "/diagnoses", params: { photos: photos }
      hash = JSON.parse(response.body)
      expect(response.status).to eq 503
      expect(hash["message"]).to eq "AI回答の取得に失敗しました"
    end

    it "returns 500 and user message when unexpected error occurs" do
      allow(Llm::DiagnoseImpression).to receive(:call).and_raise(StandardError)
      post "/diagnoses", params: { photos: photos }
      hash = JSON.parse(response.body)
      expect(response.status).to eq 500
      expect(hash["message"]).to eq "エラーが発生しました"
    end

    it "returns 503 when llm response is invalid" do
      allow(Llm::DiagnoseImpression).to receive(:call).and_raise(Llm::DiagnoseImpression::InvalidResponse)
      post "/diagnoses", params: { photos: photos }
      expect(response.status).to eq 503
    end
  end
end
