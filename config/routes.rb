require File.join(Rails.root, 'lib/resque_auth_server.rb')

HackerIo::Application.routes.draw do

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
      post 'followers' => 'project_followers#create'
      delete 'followers' => 'project_followers#destroy'
    end
    resources :blog, controller: :blog_posts, except: [:update, :create]
    resources :blog_posts, only: [:update, :create]
  end
  resources :publications, except: [:show]
  get 'blog_posts/:id' => 'blog_posts#redirect_to_show', as: :blog_post
  resources :blog_posts, only: [] do
    resources :comments, only: [:create]
  end
  resources :comments, only: [:update, :destroy]

  get 'contact' => 'contact#new'
  post 'contact' => 'contact#create'

  get 'search' => 'search#search'

  get 'profile/edit' => 'users#edit'
  put 'profile' => 'users#update'
  get 'profile/first_login' => 'users#first_login'

  get ':user_name' => 'users#show', as: :user, user_name: /[a-z0-9_]{3,}/, constraints: { format: /(html|json)/ }
  scope ':user_name', as: :user do
    post 'followers' => 'follow_relations#create'
    delete 'followers' => 'follow_relations#destroy'
  end

  root to: 'pages#home'
end
