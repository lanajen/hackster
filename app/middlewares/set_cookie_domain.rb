class SetCookieDomain
  def initialize(app, default_domain)
    @app = app
    @default_domain = default_domain
  end

  def call(env)
    if @default_domain
      host = env["HTTP_HOST"].split(':').first
      env["rack.session.options"][:domain] = custom_domain?(host) ? host : @default_domain
    end
    @app.call(env)
  end

  def custom_domain?(host)
    host !~ Regexp.new("#{@default_domain}$", Regexp::IGNORECASE)
  end
end