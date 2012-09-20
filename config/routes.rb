FacelauncherInstance::Engine.routes.draw do
  match 'inactive' => 'application#inactive'
  resources :photos, :only => :show
  resources :videos, :only => :show
  resources :signups, :programs, :photos
end
