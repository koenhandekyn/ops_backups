module OpsBackups
  class ApplicationController < ActionController::Base
    before_action :set_locale

    private

    def set_locale
      # set the locale only if the locale is available
      locale = extract_locale
      I18n.locale = locale if I18n.available_locales.map(&:to_s).include?(locale)
    end

    def extract_locale
      request.env["HTTP_ACCEPT_LANGUAGE"].split(",")&.first&.split(";")&.first.to_s
    end
  end
end
