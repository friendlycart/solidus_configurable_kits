# frozen_string_literal: true

SolidusConfigurableKits::Engine.routes.draw do
  resources :orders, only: [] do
    post :populate_kit, on: :collection
  end

  namespace :admin do
    resources :products, only: [] do
      resources :kit_requirements, controller: :kit_requirements
    end
  end
end
