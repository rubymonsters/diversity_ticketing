class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate

  def authenticate
    if session[:authenticated]
      return true
    else
      redirect_to login_path
    end
  end

  def authenticated?
    session[:authenticated]
  end

  helper_method :authenticated?
end
