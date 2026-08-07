require "ruby_llm"

class Llm::DiagnoseImpression
  class InvalidResponse < StandardError
  end

  MAX_LENGTH = 500

  def self.call(**kwargs) = new(**kwargs).call

  def initialize(photos: [])
    @photos = photos
  end

  def call
    fetch_ai_response
  end

  private

  def fetch_ai_response
    instruction_prompt = File.read(Rails.root.join("app/prompts/diagnose_impression.md"))
    chat_gemini = RubyLLM.chat(model: "gemini-2.5-flash")
    response = chat_gemini.ask "#{instruction_prompt}", with: @photos
    # config/initializers/ruby_llm.rbにretry設定

    raise InvalidResponse, "文字列超過: #{response.content.length}文字" if response.content.length > MAX_LENGTH
    response
  end
end
