RubyLLM.configure do |config|
  config.gemini_api_key = Rails.application.credentials.dig(:gemini, Rails.env.to_sym, :api_key) || "test-dummy-key"
end
