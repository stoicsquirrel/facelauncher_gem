module Facelauncher
  class Engine < ::Rails::Engine
    isolate_namespace Facelauncher

    config.facelauncher = ActiveSupport::OrderedHash.new
  end
end
