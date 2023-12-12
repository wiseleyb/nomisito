# frozen_string_literal: true

Rails.application.routes.draw do
  #   resources :home do
  #     collection do
  #       get :search
  #     end
  #   end

  root 'home#index'
end
