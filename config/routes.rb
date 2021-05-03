# frozen_string_literal: true

SolidusConfigurableKits::Engine.routes.draw do
  namespace :admin do
    resources :products, only: [] do
      resources :kit_requirements, only: :index, controller: :kit_requirements
    end
  end
end
