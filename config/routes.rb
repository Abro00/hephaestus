Rails.application.routes.draw do
  scope '(:locale)', locale: /ru|en/ do 
    root 'users#index'
    
    devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions'}
    telegram_webhook TelegramWebhooksController

    resources :users do
      resources :connections
    end
  end
end
