Rails.application.routes.draw do
  mount FacelauncherInstance::Engine => "/facelauncher"

  root :to => 'application#index'
end
