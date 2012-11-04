Rails.application.routes.draw do
  mount Facelauncher::Engine => "/facelauncher"
  resources :photos, :only => [:index, :show, :new, :create] do
    member do
      get 'redirect'
    end
  end
  root :to => 'application#index'
end
