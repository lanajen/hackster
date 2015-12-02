class RackReverseProxyMod
  def initialize(app)
    @app = app
  end

  def call(env)
    # call super if we want to proxy, otherwise just handle regularly via call
    # (proxy?(env) && super) || @app.call(env)
    env = rewrite_env(env) if proxy?(env)
    @app.call(env)
  end

  def proxy?(env)
    # do not alter env here, but return true if you want to proxy for this request.
    env['HTTP_HOST'] == ENV['ARDUINO_HOST']
  end

  def rewrite_env(env)
    # change the env here
    # raise env.inspect
    env['HTTP_HOST'] = 'arduino.localhost.local:5000'
    env["REQUEST_PATH"] = env["REQUEST_PATH"].gsub(/^\/projects/, '')
    env["PATH_INFO"] = env["PATH_INFO"].gsub(/^\/projects/, '')
    env["REQUEST_URI"] = env["REQUEST_URI"].gsub(/^\/projects/, '')
    env
  end
end