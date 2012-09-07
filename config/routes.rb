FacelauncherInstance::Engine.routes.draw do
  root :to => "application#index"
  match 'inactive' => 'application#inactive'
  resources :signups, :programs, :photos
end
