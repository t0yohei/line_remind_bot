Rails.application.routes.draw do
  post '/callback' => 'webhook#callback'
  root to: 'webhook#index'
end
