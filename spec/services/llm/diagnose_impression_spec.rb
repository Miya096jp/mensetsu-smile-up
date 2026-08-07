require "rails_helper"

RSpec.describe Llm::DiagnoseImpression, type: :model do
  describe ".call" do
    it "returns ai diagnosis" do
      RubyLLM::Test.stub_response("good impression")
      result = Llm::DiagnoseImpression.call(photos: [])
      expect(result.content).to eq "good impression"
    end

    it "returns ai diagnosis within 500 characters" do
      RubyLLM::Test.stub_response("a" * 500)
      result = Llm::DiagnoseImpression.call(photos: [])
      expect(result.content).to eq "a" * 500
    end

    it "returns InvalidResponse over 501 characters" do
      RubyLLM::Test.stub_response("a" * 501)
      expect { Llm::DiagnoseImpression.call(photos: []) }.to raise_error(Llm::DiagnoseImpression::InvalidResponse)
    end
  end
end
