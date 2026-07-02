require "rails_helper"

RSpec.describe Llm::DiagnoseImpression, type: :model do
  describe ".call" do
    it "returns ai diagnosis" do
      RubyLLM::Test.stub_response("good impression")
      result = Llm::DiagnoseImpression.call(photos: [])
      expect(result.content).to eq "good impression"
    end

    it "returns ai diagnosis at second retry after RubyLLM::ServerError" do
      chat_gemini = double()
      allow(chat_gemini).to receive(:ask).and_invoke(Proc.new { raise RubyLLM::ServerError }, Proc.new { "good impression" })
      allow(RubyLLM).to receive(:chat).and_return(chat_gemini)
      allow_any_instance_of(Llm::DiagnoseImpression).to receive(:sleep)
      expect(Llm::DiagnoseImpression.call(photos: [])).to eq("good impression")
      expect(chat_gemini).to have_received(:ask).exactly(2).times
    end

    it "returns RubyLLM::ServerError after three time retries" do
      chat_gemini = double()
      allow(RubyLLM).to receive(:chat).and_return(chat_gemini)
      allow(chat_gemini).to receive(:ask).and_raise(RubyLLM::ServerError)
      allow_any_instance_of(Llm::DiagnoseImpression).to receive(:sleep)
      expect { Llm::DiagnoseImpression.call(photos: []) }.to raise_error(RubyLLM::ServerError)
      expect(chat_gemini).to have_received(:ask).exactly(4).times
    end

    it "returns RubyLLM::BadRequestError" do
      chat_gemini = double()
      allow(RubyLLM).to receive(:chat).and_return(chat_gemini)
      allow(chat_gemini).to receive(:ask).and_raise(RubyLLM::BadRequestError)
      expect { Llm::DiagnoseImpression.call(photos: []) }.to raise_error(RubyLLM::BadRequestError)
      expect(chat_gemini).to have_received(:ask).exactly(1).times
    end
  end
end
