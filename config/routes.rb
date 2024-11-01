Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

#merchants below
  get "/api/v1/merchants", to: "api/v1/merchants#index"
  get "/api/v1/merchants/:id", to: "api/v1/merchants#show"
  delete "/api/v1/merchants/:id", to: "api/v1/merchants#destroy"
  post "/api/v1/merchants", to: "api/v1/merchants#create"
  patch "/api/v1/merchants/:id", to: "api/v1/merchants#update"

#items below
  get "/api/v1/items", to: "api/v1/items#index"
  get "/api/v1/items/:id", to: "api/v1/items#show"
  delete "/api/v1/items/:id", to: "api/v1/items#destroy"
  post "/api/v1/items", to: "api/v1/items#create"
  put "/api/v1/items/:id", to: "api/v1/items#update"

#relationships
  get "/api/v1/merchants/:id/items", to: "api/v1/merchant_items#index"
  get "/api/v1/items/:id/merchant", to: "api/v1/item_merchants#index"

#other 
#  get "/api/v1/merchants/:id/items", to: "api/v1/item_merchants#index" #get items belonging to a specific merchant
end
