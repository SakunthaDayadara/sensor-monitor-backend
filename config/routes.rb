Rails.application.routes.draw do
  resources :sensor_thresholds
  resources :sensor_data
  resources :sensors
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
