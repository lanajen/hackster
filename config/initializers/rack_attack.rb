class Rack::Attack
  TRUSTED_USER_AGENTS = ['NewRelicPinger/1.0',
    'Slackbot 1.0 (+https://api.slack.com/robots)']

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Always allow requests from localhost
  # (blacklist & throttles are skipped)
  whitelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    '127.0.0.1' == req.ip
  end
  whitelist('trusted_ua') do |req|
    TRUSTED_USER_AGENTS.each do |ua|
      ua.in? req.user_agent
    end if req.user_agent
  end

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're probably
  # malicious or a poorly-configured scraper. Either way, they don't deserve
  # to hog all of the app server's CPU. Cut them off!

  # Throttle all requests by IP (20rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', limit: 100, period: 5.minutes) do |req|
    if req.get? and !req.xhr?
      req.ip
    end
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password attack
  # where an attacker simply tries a large number of emails and passwords to
  # see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  throttle('logins/ip', :limit => 5, :period => 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock on
  # wood!)
  throttle("logins/email", :limit => 5, :period => 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      # return the email if present, nil otherwise
      req.params['email'].presence
    end
  end

  # Block logins from a bad user agent
  blacklist('block scraper access') do |req|
    req.user_agent =~ /23\.0\.1271\.97/ or (range = IPCat.datacenter?(req.ip) and range.name == 'Amazon AWS' and req.path != '/ping') or req.ip == '78.110.60.230'
  end
  track('bad_scraper') do |req|
    req.user_agent =~ /23\.0\.1271\.97/ or (range = IPCat.datacenter?(req.ip) and range.name == 'Amazon AWS' and req.path != '/ping')
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  # throttled_response = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    ['']] # body
  # end

  blacklisted_response = lambda do |env|
    # Using 503 because it may make attacker think that they have successfully
    # DOSed the site. Rack::Attack returns 403 for blacklists by default
    [ 503, {}, ['Blocked']]
  end
end

ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, req|
  Rails.logger.debug "user_agent: " + req.user_agent
  Rails.logger.debug "ip: " + req.ip
  Rails.logger.debug "remote_ip: " + req.remote_ip
  if req.env['rack.attack.matched'] == "block scraper access" && req.env['rack.attack.match_type'] == :blacklist
    Rails.logger.info "bad_scraper: #{req.path} / #{req.user_agent} / #{req.ip}"
    # Rails.logger.info req.inspect
    # STATSD.increment("bad_scraper")
  end
end