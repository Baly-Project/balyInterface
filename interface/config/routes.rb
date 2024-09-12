Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "pages#home"
  get "index/:sortparam/:start/:last" => "slides#index"
  get "slides/range/:range" => "slides#range"
  get "slides/:id" => "slides#show"
  get "years/all" => "years#index"
  get "years/:number" => "years#show"
  get "places/all" => "countries#index"
  get "places/countries/:id" => "countries#show"
  get "places/regions/:id" => "regions#show"
  get "places/cities/:id" => "cities#show"
  get "places/locations/:id" => "locations#show"
  get "collections/all" => "collections#index"
  get "collections/:alph" => "collections#show"
  get "stamps/all" => "stamps#index"
  get "stamps/:id" => "stamps#show"
  get "keywords/all" => "keywords#index"
  get "keywords/:id" => "keywords#show"
  get "home" => "pages#home"
  get "timeline" => "pages#timeline"
  get "about" => "pages#about"
end
