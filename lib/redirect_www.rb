class RedirectWWW
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["SERVER_NAME"] == "www.diversitytickets.org"
      req = Rack::Request.new(env)
      uri = "https://diversitytickets.org#{req.fullpath}"
      return [301, {"Location" => uri}, []]
    end
    @app.call(env)
  end
end