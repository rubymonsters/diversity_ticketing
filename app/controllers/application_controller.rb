class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate

  def authenticate
    if authenticate_or_request_with_http_basic { |u, p| u == ENV['DT_USERNAME'] && p == ENV['DT_PASSWORD'] }
      session[:authenticated] = true
    else
      session[:authenticated] = false
      request_http_basic_authentication
    end
  end

  def authenticated?
    session[:authenticated]
  end

  helper_method :authenticated?
end
