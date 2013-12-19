require File.join(Rails.root, 'lib/resque_auth_server.rb')

HackerIo::Application.routes.draw do


  constraints subdomain: /beta/ do
    match '(*any)' => redirect { |params, request|
      URI.parse(request.url).tap { |uri| uri.host.sub!(/^beta\./i, 'www.') }.to_s
    }, via: :get
  end

  constraints subdomain: /www/ do
    get 'sitemap_index.xml' => 'sitemap#index', as: 'sitemap_index', defaults: { format: 'xml' }
    get 'sitemap.xml' => 'sitemap#show', as: 'sitemap', defaults: { format: 'xml' }

    devise_for :users, controllers: {
      confirmations: 'users/confirmations',
      invitations: 'users/invitations',
      omniauth_callbacks: 'users/omniauth_callbacks',
      sessions: 'users/sessions',
      registrations: 'users/registrations',
    }

    devise_scope :user do
      namespace :users, as: '' do
        resources :authorizations
        match '/auth/:provider/setup' => 'omniauth_callbacks#setup', via: :get
      end
    end

    namespace :admin do
      mount ResqueAuthServer.new, at: "/resque"
      get 'analytics' => 'pages#analytics'
      get 'logs' => 'pages#logs'

      resources :invite_codes, except: [:show]
      resources :invite_requests do
        patch 'send_invite' => 'invite_requests#send_invite', on: :member
      end
      resources :projects
#      resources :quotes
      resources :users

      root to: 'pages#root'
    end

#    get 'blog_posts/:id' => 'thread_posts#redirect_to_show', as: :blog_post
#    resources :blog_posts, controller: :thread_posts, only: [] do
#      resources :comments, only: [:create]
#    end
#    get 'issues/:id' => 'thread_posts#redirect_to_show', as: :issue
#    resources :issues, controller: :thread_posts, only: [] do
#      resources :comments, only: [:create]
#    end
    resources :comments, only: [:update, :destroy]
    resources :files, only: [:create, :destroy]
    resources :invite_requests, only: [:create, :update, :edit]
    # get 'request/an/invite' => 'invite_requests#new', as: :new_invite_request
    delete 'notifications' => 'notifications#destroy'
    resources :projects do
      member do
#        get 'followers' => 'project_followers#index', as: :followers
#        post 'followers' => 'project_followers#create'
#        delete 'followers' => 'project_followers#destroy'
        get 'embed'
        get 'team_members' => 'team_members#edit', as: :edit_team_members
        patch 'team_members' => 'team_members#update'
      end
      resources :comments, only: [:create]
      resources :respects, only: [:create] do
        delete '' => 'respects#destroy', on: :collection
      end
#      resources :blog_posts, controller: :thread_posts
#      resources :issues, controller: :thread_posts
#      resources :participant_invites, only: [:index]
      resources :widgets
      patch 'widgets' => 'widgets#save'
    end
#    resources :publications, except: [:show]
#    resources :stages, only: [] do
#      patch 'update_workflow', on: :member
#    end
    resources :widgets, only: [] do
#      resources :issues, except: [:index], controller: :thread_posts
    end

#    get 'privacy/:type/:id/edit' => 'privacy_settings#edit', as: :edit_privacy_settings
#    post 'privacy/:type/:id' => 'privacy_settings#create', as: :privacy_settings
#    patch 'privacy/:type/:id' => 'privacy_settings#update'
#    delete 'privacy/:type/:id' => 'privacy_settings#destroy'
#
#    patch 'issues/:id/update_workflow' => 'thread_posts#update_workflow', as: :issue_update_workflow

    get 'users/registration/complete_profile' => 'users#after_registration', as: :user_after_registration
    patch 'users/registration/complete_profile' => 'users#after_registration_save'


    get 'contact' => 'contact#new'
    post 'contact' => 'contact#create'

    get 'help' => 'pages#help'
    get 'home', to: redirect('/')

    get 'ping' => 'pages#ping'  # for availability monitoring
    get 'obscure/path/to/cron' => 'cron#run'

    get 'profile/edit' => 'users#edit'
    patch 'profile' => 'users#update'

    get 'search' => 'search#search'

    get ':user_name' => 'users#show', as: :user, user_name: /[A-Za-z0-9_]{3,}/, constraints: { format: /(html|json)/ }
    scope ':user_name', as: :user do
#      post 'followers' => 'follow_relations#create'
#      delete 'followers' => 'follow_relations#destroy'
    end

    root to: 'pages#home'
  end
end
