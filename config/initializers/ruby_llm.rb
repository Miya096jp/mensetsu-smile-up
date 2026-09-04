RubyLLM.configure do |config|
  config.gemini_api_key = ENV["GEMINI_API_KEY"] || "test-dummy-key"

  config.request_timeout = 30
  config.max_retries = 1
  config.retry_interval = 1
  config.retry_backoff_factor = 3
end
