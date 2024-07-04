# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  scope path: "/api/v1/", module: "v1", as: "v1", defaults: { format: :json } do
    namespace :admin do
      resources :courses, only: %i[index show create update destroy]
    end
  end
end
