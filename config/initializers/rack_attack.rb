class Rack::Attack
  throttle("req/ip", limit: 3, period: 1.minutes) do |req|
    req.ip if req.path == "/diagnoses" && req.post?
  end

  DIAGNOSES_DAILY_LIMIT = 100

  throttle("diagnoses/global",
           limit: ->(_req) { DIAGNOSES_DAILY_LIMIT },
           period: 1.day) do |req|
    "global" if req.post? && req.path == "/diagnoses"
  end

  DIAGNOSES_IP_DAILY_LIMIT = 10

  throttle("diagnoses/ip-daily",
           limit: ->(_req) { DIAGNOSES_IP_DAILY_LIMIT },
           period: 1.day) do |req|
    req.ip if req.post? && req.path == "/diagnoses"
  end

  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |name, start, finish, instrumenter_id, payload|
    res = payload[:request].env["rack.attack.match_data"]
    Rails.logger.warn(
    "[RackAttack] Throttled ip: #{res[:discriminator]} limit: #{res[:limit]} count: #{res[:count]}"
    )
  end
end
