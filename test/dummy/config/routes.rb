Rails.application.routes.draw do
  mount FacelauncherInstance::Engine => "/facelauncher_instance"

  root :to => 'application#index'
end
