module Facelauncher
  class Program < ActiveResource::Base
    self.site = ENV.key?('FACELAUNCHER_URL') ? ENV['FACELAUNCHER_URL'] : Facelauncher::Engine.config.server_url
    self.format = :json
    self.user = ENV.key?('FACELAUNCHER_PROGRAM_ID') ? ENV['FACELAUNCHER_PROGRAM_ID'] : Facelauncher::Engine.config.program_id
    self.password = ENV.key?('FACELAUNCHER_PROGRAM_ACCESS_KEY') ? ENV['FACELAUNCHER_PROGRAM_ACCESS_KEY'] : Facelauncher::Engine.config.program_access_key
  end
end
