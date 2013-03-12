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
  resources :projects do
    member do
      get 'followers' => 'project_followers#index', as: :followers
      post 'followers' => 'project_followers#create', as: :followers
      delete 'followers' => 'project_followers#destroy', as: :followers
    end
  end

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
