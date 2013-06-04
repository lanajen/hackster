require File.join(Rails.root, 'lib/resque_auth_server.rb')

HackerIo::Application.routes.draw do

  get 'sitemap_index.xml' => 'sitemap#index', as: 'sitemap_index', defaults: { format: 'xml' }
  get 'sitemap.xml' => 'sitemap#show', as: 'sitemap', defaults: { format: 'xml' }
  
  constraints subdomain: /beta/ do
    devise_for :users, controllers: {
      :registrations => 'users/registrations',
      :confirmations => 'users/confirmations',
      :invitations => 'users/invitations',
    }

    namespace :admin do
      mount ResqueAuthServer.new, at: "/resque"
      get 'logs' => 'pages#logs'

      resources :invite_requests
      resources :projects
      resources :quotes
      resources :users

      root to: 'pages#root'
    end

    get 'blog_posts/:id' => 'thread_posts#redirect_to_show', as: :blog_post
    resources :blog_posts, controller: :thread_posts, only: [] do
      resources :comments, only: [:create]
    end
    get 'issues/:id' => 'thread_posts#redirect_to_show', as: :issue
    resources :issues, controller: :thread_posts, only: [] do
      resources :comments, only: [:create]
    end
    resources :comments, only: [:update, :destroy]
    resources :invite_requests, only: [:new, :create]
    resources :projects, except: [:index] do
      member do
        get 'followers' => 'project_followers#index', as: :followers
        post 'followers' => 'project_followers#create'
        delete 'followers' => 'project_followers#destroy'
        get 'team_members' => 'team_members#edit', as: :edit_team_members
        put 'team_members' => 'team_members#update'
      end
      resources :blog_posts, controller: :thread_posts
      resources :issues, controller: :thread_posts
      resources :participant_invites, only: [:index]
      resources :widgets
      put 'widgets' => 'widgets#save'
    end
    resources :publications, except: [:show]
    resources :stages, only: [] do
      put 'update_workflow', on: :member
    end
    resources :widgets, only: [] do
      resources :issues, except: [:index], controller: :thread_posts
    end

    get 'privacy/:type/:id/edit' => 'privacy_settings#edit', as: :edit_privacy_settings
    post 'privacy/:type/:id' => 'privacy_settings#create', as: :privacy_settings
    put 'privacy/:type/:id' => 'privacy_settings#update'
    delete 'privacy/:type/:id' => 'privacy_settings#destroy'

    put 'issues/:id/update_workflow' => 'thread_posts#update_workflow', as: :issue_update_workflow

    get 'help' => 'pages#help'

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

  constraints subdomain: /www/ do
#    resources :quotes, only: [:create]
#    get 'find_a_manufacturer' => 'quotes#new'
#    get 'quote_requested' => 'quotes#requested'

    resources :invite_requests, only: [:create] do
      get 'confirm', on: :collection
    end

    root to: 'invite_requests#new'
  end
end
