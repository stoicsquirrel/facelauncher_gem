module Facelauncher
  class ProgramApp < Facelauncher::Model
    authentication_required_on :find
    cache_expiration(ENV.key?("FACELAUNCHER_APP_CACHE_EXPIRATION") ? ENV["FACELAUNCHER_APP_CACHE_EXPIRATION"] : 15.minutes)

    self.attributes = [
      :id, :program_id, :app_url, :name, :description, :facebook_app_id, :facebook_app_secret,
      :facebook_app_access_token, :google_analytics_tracking_code, :created_at, :updated_at
    ]
  end
end