module FacelauncherInstance
  class Program < ActiveResource::Base
    self.site = FacelauncherInstance::Engine.config.server_url
    self.format = :json
    self.user = FacelauncherInstance::Engine.config.program_id
    self.password = FacelauncherInstance::Engine.config.program_access_key
  end
end
