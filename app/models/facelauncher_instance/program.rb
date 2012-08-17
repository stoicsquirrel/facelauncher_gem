module FacelauncherInstance
  class Program < ActiveResource::Base
    self.site = "http://localhost:5000/"
    self.format = :json
  end
end
