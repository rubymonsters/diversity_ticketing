class ApplicationController < ActionController::Base
  include Clearance::Controller
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_login
  before_action :set_locale

  def build_missing_translations(object)
    I18n.available_locales.each do |locale|
      object.translations.build(locale: locale) unless object.translated_locales.include?(locale)
    end
  end

  def set_locale
    desired_locale = request.headers['HTTP_ACCEPT_LANGUAGE'].to_s[0..1] == 'es' ? 'es' : 'en'
    pp "PARAMS"
    pp params[:locale]
    pp "DESIRED LOCALE"
    pp desired_locale
    # I18n.locale = params[:locale] || desired_locale
    pp I18n.locale
    I18n.locale = :es
  end
  def require_admin
    redirect_to root_path unless admin_user?
  end

  def admin_user?
    signed_in? && current_user.admin?
  end

  helper_method :admin_user?
end
