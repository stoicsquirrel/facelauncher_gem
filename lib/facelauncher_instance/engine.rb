module FacelauncherInstance
  class Engine < ::Rails::Engine
    isolate_namespace FacelauncherInstance

    config.facelauncher_instance = ActiveSupport::OrderedHash.new
  end
end
