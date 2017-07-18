class ApplicationController < ActionController::Base
  include Clearance::Controller
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_login

  def require_admin
    redirect_to root_path unless admin_user?
  end

  def admin_user?
    signed_in? && current_user.admin?
  end

  helper_method :admin_user?
end
