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
      resources :projects, except: [:show]
      resources :users, except: [:show]

      root to: 'pages#root'
    end

    resources :comments, only: [:update, :destroy]
    # resources :groups do
    #   get 'qa'
    # end
    resources :files, only: [:create, :destroy]
    resources :invite_requests, only: [:create, :update, :edit]
    # get 'request/an/invite' => 'invite_requests#new', as: :new_invite_request
    delete 'notifications' => 'notifications#destroy'

    resources :projects, except: [:show, :update, :destroy] do
      member do
        get '' => 'projects#redirect_old_show_route', constraints: lambda{|req| req.params[:id] != 'new' }
        get 'embed'
        get 'team' => 'teams#edit', as: :edit_team
        get 'team_members', to: redirect{ |params, req| "/projects/#{params[:id]}/team" }  # so that task rabitters don't get confused
        patch 'team' => 'teams#update'
      end
      collection do
        resources :imports, only: [:new, :create], controller: :project_imports, as: :project_imports do
          post 'submit', on: :collection
        end
      end
      resources :comments, only: [:create]
      resources :respects, only: [:create] do
        delete '' => 'respects#destroy', on: :collection
      end
      resources :widgets
      patch 'widgets' => 'widgets#save'
    end

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
    get 'tags/:tag' => 'search#tags', as: :tags
    get 'tags' => 'search#tags'

    get 'infringement_policy' => 'pages#infringement_policy'
    get 'privacy' => 'pages#privacy'
    get 'terms' => 'pages#terms'

    get ':user_name' => 'users#show', as: :user, user_name: /[A-Za-z0-9_]{3,}/, constraints: { format: /(html|json)/ }

    scope ':user_name/:project_slug', as: :project, user_name: /[A-Za-z0-9_]{3,}/, project_slug: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json|js)/ } do
      get '' => 'projects#show', as: ''
      delete '' => 'projects#destroy'
      patch '' => 'projects#update'
    end

    root to: 'pages#home'
  end
end
