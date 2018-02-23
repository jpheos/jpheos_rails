Rails.application.routes.draw do
  namespace :annijour do
    get '/', to: 'contacts#dashboard'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :contacts, only: :index do
    collection do
      get :synchronization
    end
  end

  namespace :pushbullet do
    get :connect, to: 'oauth#connect'
    get :callback, to: 'oauth#callback'
    get :select_device, to: 'oauth#select_device_form'
    post :select_device, to: 'oauth#select_device'
  end

  root to: "application#home"
end

