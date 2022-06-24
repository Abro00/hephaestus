Rails.application.routes.draw do
  root 'users#index'

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions'}
  telegram_webhook TelegramWebhooksController

  resources :users do
    resources :connections
  end
end
