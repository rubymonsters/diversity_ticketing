class ApplicationController < ActionController::Base
  include Clearance::Controller
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :require_login

  def default_url_options
    { locale: I18n.locale }
  end

  def set_locale
    I18n.locale = params[:locale] || :en
  end

  def require_admin
    redirect_to root_path unless admin_user?
  end

  def admin_user?
    signed_in? && current_user.admin?
  end

  def selection_by_dt_enabled?
    ApplicationProcessOptionsHandler.first.selection_by_dt_enabled
  end

  helper_method :admin_user?
  helper_method :selection_by_dt_enabled?
end
