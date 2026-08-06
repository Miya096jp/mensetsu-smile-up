RubyLLM.configure do |config|
  config.gemini_api_key = ENV["GEMINI_API_KEY"] || "test-dummy-key"

  config.max_retries = 3
  config.retry_interval = 1
  config.retry_backoff_factor = 3
end
