require File.join(Rails.root, 'lib/resque_auth_server.rb')

Halckemy::Application.routes.draw do

  devise_for :users, controllers: {
    :registrations => 'users/registrations',
    :confirmations => 'users/confirmations',
    :invitations => 'users/invitations',
  }

  namespace :admin do
    mount ResqueAuthServer.new, at: "/resque"
  end

  resources :invite_requests, only: [:new, :create]
  resources :projects

  get 'contact' => 'contact#new'
  post 'contact' => 'contact#create'
  get ':user_name' => 'users#show', as: :user_profile
  scope ':user_name' do
    post 'followers' => 'follow_relations#create'
    delete 'followers' => 'follow_relations#destroy'
  end
  get 'profile/edit' => 'users#edit'
  put 'profile' => 'users#update'

  root to: 'pages#home'
end
