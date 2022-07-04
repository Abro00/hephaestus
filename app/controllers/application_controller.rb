class ApplicationController < ActionController::Base
  before_action :set_locale

  protected

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    parsed_locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  def default_url_options
    if I18n.locale == I18n.default_locale
      { locale: nil }
    else
      { locale: I18n.locale }
    end
  end
end
