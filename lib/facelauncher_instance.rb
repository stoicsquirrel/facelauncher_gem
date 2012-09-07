require "facelauncher_instance/engine"

module FacelauncherInstance
  def self.setup
    yield self
  end

  mattr_accessor :facelauncher_server_url
  @@facelauncher_server_url = "http://localhost:5000/"

  # Facelauncher API Program ID
  mattr_accessor :program_id
  @@program_id = 0

  # Facelauncher API Program Access Key
  mattr_accessor :program_access_key
  @@program_access_key = ""
end
