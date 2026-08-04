class Rack::Attack
  throttle("req/ip", limit: 60, period: 1.minutes) do |req|
    req.ip if req.path == "/diagnoses" && req.post?
  end

  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |name, start, finish, instrumenter_id, payload|
    res = payload[:request].env["rack.attack.match_data"]
    Rails.logger.warn(
    "[RackAttack] Throttled ip: #{res[:discriminator]} limit: #{res[:limit]} count: #{res[:count]}"
    )
  end
end
