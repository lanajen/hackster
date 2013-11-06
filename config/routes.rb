require File.join(Rails.root, 'lib/resque_auth_server.rb')

HackerIo::Application.routes.draw do


  constraints subdomain: /beta/ do
    match '(*any)' => redirect { |params, request|
      URI.parse(request.url).tap { |uri| uri.host.sub!(/^beta\./i, 'www.') }.to_s
    }
  end

  constraints subdomain: /www/ do
    get 'sitemap_index.xml' => 'sitemap#index', as: 'sitemap_index', defaults: { format: 'xml' }
    get 'sitemap.xml' => 'sitemap#show', as: 'sitemap', defaults: { format: 'xml' }

    devise_for :users, controllers: {
      confirmations: 'users/confirmations',
      invitations: 'users/invitations',
      sessions: 'users/sessions',
      registrations: 'users/registrations',
    }

    namespace :admin do
      mount ResqueAuthServer.new, at: "/resque"
      get 'logs' => 'pages#logs'

      resources :invite_codes, except: [:show]
      resources :invite_requests do
        put 'send_invite' => 'invite_requests#send_invite', on: :member
      end
      resources :projects
      resources :users

      root to: 'pages#root'
    end

    resources :comments, only: [:update, :destroy]
    resources :groups do
      get 'qa'
    end
    resources :invite_requests, only: [:create, :update, :edit]
    # get 'request/an/invite' => 'invite_requests#new', as: :new_invite_request
    resources :projects, except: [:index] do
      member do
#        get 'followers' => 'project_followers#index', as: :followers
#        post 'followers' => 'project_followers#create'
#        delete 'followers' => 'project_followers#destroy'
        get 'team_members' => 'team_members#edit', as: :edit_team_members
        put 'team_members' => 'team_members#update'
      end
      resources :comments, only: [:create]
      resources :respects, only: [:create] do
        delete '' => 'respects#destroy', on: :collection
      end
      resources :widgets
      put 'widgets' => 'widgets#save'
    end

    get 'users/registration/complete_profile' => 'users#after_registration', as: :user_after_registration
    put 'users/registration/complete_profile' => 'users#after_registration_save'


    get 'contact' => 'contact#new'
    post 'contact' => 'contact#create'

    get 'help' => 'pages#help'
    get 'home' => 'pages#home'

    get 'obscure/path/to/cron' => 'cron#run'

    get 'profile/edit' => 'users#edit'
    put 'profile' => 'users#update'
    get 'profile/first_login' => 'users#first_login'

    get 'search' => 'search#search'

    get ':user_name' => 'users#show', as: :user, user_name: /[a-z0-9_]{3,}/, constraints: { format: /(html|json)/ }
    scope ':user_name', as: :user do
#      post 'followers' => 'follow_relations#create'
#      delete 'followers' => 'follow_relations#destroy'
    end

    get '' => 'invite_requests#new', as: :new_invite_request
    root to: 'invite_requests#new'
  end
end
