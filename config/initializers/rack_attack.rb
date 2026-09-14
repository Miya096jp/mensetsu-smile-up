class Rack::Attack
  DIAGNOSES_PATH_PATTERN = %r{\A/diagnoses(\.[^/.]+)?/?\z}

  throttle("req/ip", limit: 2, period: 1.minutes) do |req|
    req.ip if DIAGNOSES_PATH_PATTERN.match?(req.path) && req.post?
  end

  DIAGNOSES_DAILY_LIMIT = 100

  throttle("diagnoses/global",
           limit: ->(_req) { DIAGNOSES_DAILY_LIMIT },
           period: 1.day) do |req|
    "global" if req.post? && DIAGNOSES_PATH_PATTERN.match?(req.path)
  end

  DIAGNOSES_IP_DAILY_LIMIT = 10

  throttle("diagnoses/ip-daily",
           limit: ->(_req) { DIAGNOSES_IP_DAILY_LIMIT },
           period: 1.day) do |req|
    req.ip if req.post? && DIAGNOSES_PATH_PATTERN.match?(req.path)
  end

  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |name, start, finish, instrumenter_id, payload|
    res = payload[:request].env["rack.attack.match_data"]
    Rails.logger.warn(
    "[RackAttack] Throttled ip: #{res[:discriminator]} limit: #{res[:limit]} count: #{res[:count]}"
    )
  end
end
