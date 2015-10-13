class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      @authenticated = username == ENV['DT_USERNAME'] && password == ENV['DT_PASSWORD']
      session[:authenticated] = @authenticated
    end
  end

  def authenticated?
    session[:authenticated]
  end

  helper_method :authenticated?
end
