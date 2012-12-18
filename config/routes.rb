Facelauncher::Engine.routes.draw do
  match 'inactive' => 'application#inactive'
  match 'clear-cache' => 'application#clear_cache', :as => 'clear_cache'
  resources :photos, :only => [:index, :show, :new, :create] do
    member do
      get 'redirect'
    end
  end
  resources :videos, :only => [:index, :show] do
    member do
      get 'redirect'
    end
  end
  resources :signups, :programs, :photos
end
