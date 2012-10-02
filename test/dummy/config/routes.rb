Rails.application.routes.draw do
  mount FacelauncherInstance::Engine => "/facelauncher"
  resources :photos, :only => [:index, :show, :new, :create] do
    member do
      get 'redirect'
    end
  end
  root :to => 'application#index'
end
