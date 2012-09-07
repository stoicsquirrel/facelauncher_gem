module FacelauncherInstance
  class Program < ActiveResource::Base
    self.site = "http://localhost:5000/" #FacelauncherInstance.setup.config.facelauncher_server_url
    self.format = :json
    self.user = '1'
    self.password = '8f059923fccb3a15320b4716b92ad09a'
  end
end
