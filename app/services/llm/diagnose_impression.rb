require "ruby_llm"

class Llm::DiagnoseImpression
  def self.call(**kwargs) = new(**kwargs).call

  def initialize(photos: [])
    @photos = photos
  end

  def call
    fetch_ai_response
  end

  def fetch_ai_response
    instruction_prompt = File.read(Rails.root.join("app/prompts/diagnose_impression.md"))
    chat_gemini = RubyLLM.chat(model: "gemini-2.5-flash")
    chat_gemini.ask "#{instruction_prompt}", with: @photos
  end
end
