Rails.application.routes.draw do
  # resources :musics
  resources :artists
  resources :users
  namespace :auth do
    post '/login', to: 'sessions#login'
    delete '/logout', to: 'sessions#logout'
  end
  post 'artists-import', to: 'artists#import'
  post 'musics-import', to: 'musics#import'
  get 'musics/:artist_id', to: 'musics#index'
  delete 'musics/:id', to: 'musics#destroy'
  post 'musics/:artist_id', to: 'musics#create'
  put 'musics/:artist_id/:id', to: 'musics#update'
  post 'register', to: 'users#register'
  get 'export-artist', to: 'artists#export', as: 'artist-export'
  get 'export-user', to: 'users#export', as: 'user-export'
  get 'export-music', to: 'musics#export', as: 'music-export'
  post 'user-import', to: 'users#import'



  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
