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
      retry_count = 0
    begin
      chat_gemini.ask "#{instruction_prompt}", with: @photos
    rescue RubyLLM::RateLimitError, RubyLLM::ServerError, RubyLLM::ServiceUnavailableError, RubyLLM::OverloadedError
      retry_count += 1
      if retry_count <= 3
        sleep(2 ** retry_count)
        retry
      else
        raise
      end
    end
  end
end
