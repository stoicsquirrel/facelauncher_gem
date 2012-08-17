FacelauncherInstance::Engine.routes.draw do
  root :to => "application#index"
  match 'inactive' => 'application#inactive' #, :as => :purchase
  resources :signups, :programs
end
