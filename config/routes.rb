YSAppBuilder::Application.routes.draw do
  namespace :embed do
    resources :projects, only: [:new, :create, :show, :edit, :update]
  end

  resources :projects do
    resources :builds, except: [:edit, :update, :destroy]
  end

  resources :qr, only: [:show]

  root to: 'projects#index'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
