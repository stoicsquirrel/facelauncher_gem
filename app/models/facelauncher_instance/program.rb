module FacelauncherInstance
  class Program < ActiveResource::Base
    self.site = ENV.key?('FACELAUNCHER_URL') ? ENV['FACELAUNCHER_URL'] : FacelauncherInstance::Engine.config.server_url
    self.format = :json
    self.user = ENV.key?('FACELAUNCHER_PROGRAM_ID') ? ENV['FACELAUNCHER_PROGRAM_ID'] : FacelauncherInstance::Engine.config.program_id
    self.password = ENV.key?('FACELAUNCHER_PROGRAM_ACCESS_KEY') ? ENV['FACELAUNCHER_PROGRAM_ACCESS_KEY'] : FacelauncherInstance::Engine.config.program_access_key
  end
end
