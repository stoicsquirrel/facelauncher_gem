require "facelauncher_instance/engine"

module FacelauncherInstance
  def self.setup
    yield self
  end

  # Facelauncher API Program ID
  mattr_accessor :program_id
  @@program_id = 0

  # Facelauncher API Program Access Key
  mattr_accessor :program_access_key
  @@program_access_key = ""
end
