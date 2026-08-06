require "rails_helper"

RSpec.describe Llm::DiagnoseImpression, type: :model do
  describe ".call" do
    it "returns ai diagnosis" do
      RubyLLM::Test.stub_response("good impression")
      result = Llm::DiagnoseImpression.call(photos: [])
      expect(result.content).to eq "good impression"
    end
  end
end
