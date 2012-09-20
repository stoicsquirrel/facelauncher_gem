FacelauncherInstance::Engine.routes.draw do
  match 'inactive' => 'application#inactive'
  resources :signups, :programs, :photos
end
