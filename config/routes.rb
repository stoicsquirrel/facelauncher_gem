FacelauncherInstance::Engine.routes.draw do
  match 'inactive' => 'application#inactive'
  resources :photos, :only => [:show, :new, :create] do
    member do
      get 'redirect'
    end
  end
  resources :videos, :only => :show
  resources :signups, :programs, :photos
end
