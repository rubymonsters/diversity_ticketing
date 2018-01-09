Clearance.configure do |config|
  config.routes = false
  config.mailer_sender = "info@diversitytickets.org"
  config.cookie_domain = ".diversitytickets.org"
  config.secure_cookie = true
  config.httponly = true
end
