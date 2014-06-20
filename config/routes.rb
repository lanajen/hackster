require 'route_constraints'
require 'sidekiq/web'

HackerIo::Application.routes.draw do

  constraints subdomain: /beta/ do
    match '(*any)' => redirect { |params, request|
      URI.parse(request.url).tap { |uri| uri.host.sub!(/^beta\./i, 'www.') }.to_s
    }, via: :get
  end

  constraints(MainSite) do
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

    mount Monologue::Engine, at: '/blog'

    namespace :admin do
      # mount ResqueAuthServer.new, at: "/resque"
      authenticate :user, lambda { |u| u.is? :admin } do
        mount Sidekiq::Web => '/sidekiq'
      end
      get 'analytics' => 'pages#analytics'
      get 'build_logs' => 'pages#build_logs'
      get 'comments' => 'pages#comments'
      get 'issues' => 'pages#issues'
      get 'logs' => 'pages#logs'
      get 'respects' => 'pages#respects'
      get 'teches' => 'pages#teches'
      get 'followers' => 'pages#followers'
      delete 'sidekiq/failures' => 'pages#clear_sidekiq_failures'

      resources :invite_codes, except: [:show]
      resources :invite_requests do
        patch 'send_invite' => 'invite_requests#send_invite', on: :member
      end
      resources :groups, except: [:show]
      resources :projects, except: [:show]
      resources :users, except: [:show]

      root to: 'pages#root'
    end  # end admin

    resources :comments, only: [:edit, :update, :destroy]
    resources :communities, except: [:show, :update, :destroy], controller: 'groups', as: :groups
    resources :groups, only: [] do
      post 'members' => 'members#create', as: :members
      get 'members/edit' => 'members#edit', as: :edit_members
      patch 'members' => 'members#update'
      get 'invitations' => 'group_invitations#index', as: :invitations
      get 'invitations/new' => 'group_invitations#new', as: :new_invitations
      post 'invitations' => 'group_invitations#create'
      get 'invitations/accept' => 'group_invitations#accept', as: :accept_invitation
      get 'awards/edit' => 'grades#edit', as: :edit_awards
      patch 'awards' => 'grades#update'
    end
    resources :members, only: [] do
      patch 'process' => 'members#process_request'
    end
    get 'groups/:id' => 'groups#show'
    get 'c/:user_name' => 'groups#show', as: :community
    scope 'c/:user_name', as: :group do
      get '' => 'groups#show', as: ''
      delete '' => 'groups#destroy'
      patch '' => 'groups#update'
    end
    resources :teches, except: [:show] do
      resources :projects, only: [] do
        post 'feature' => 'teches#feature_project'#, as: :tech_feature_project
        delete 'feature' => 'teches#unfeature_project'
      end
    end
    # resources :courses, except: [:show, :update, :destroy]
    resources :promotions, except: [:show, :update, :destroy]
    scope 'courses/:uni_name/:user_name', as: :course do
      get '' => 'courses#show', as: ''
      # delete '' => 'courses#destroy'
      # patch '' => 'courses#update'

      scope ':promotion_name', as: :promotion do
        get '' => 'promotions#show', as: ''
        delete '' => 'promotions#destroy'
        patch '' => 'promotions#update'

        resources :assignments, only: [:new, :create, :show] do
          get 'embed', on: :member
          patch 'projects/link' => 'assignments#link'
          resources :projects, only: [:new, :create], controller: 'groups/projects'
        end
      end
    end
    resources :assignments, only: [:edit, :update, :destroy]

    resources :events, except: [:show, :update, :destroy]
    scope 'hackathons/:user_name', as: :hackathon do
      get '' => 'hackathons#show', as: ''
      # delete '' => 'hackathons#destroy'
      # patch '' => 'hackathons#update'

      scope ':event_name', as: :event do
        get '' => 'events#show', as: ''
        delete '' => 'events#destroy'
        patch '' => 'events#update'
        resources :projects, only: [:new, :create], controller: 'groups/projects'
        patch 'projects/link' => 'groups/projects#link'
        resources :pages, except: [:index, :show, :destroy], controller: 'wiki_pages'
        get 'pages/:slug' => 'wiki_pages#show'
        get 'participants' => 'events#participants'
        get 'organizers' => 'events#organizers'
        get 'embed' => 'events#embed'
      end
    end

    resources :files, only: [:create, :show] do
      get 'signed_url', on: :collection
    end
    resources :invite_requests, only: [:create, :update, :edit]
    # get 'request/an/invite' => 'invite_requests#new', as: :new_invite_request
    delete 'notifications' => 'notifications#destroy'

    resources :projects, except: [:show, :update, :destroy] do
      post 'claim' => 'projects#claim_external', on: :member
      get 'last' => 'projects#redirect_to_last', on: :collection
      get '' => 'projects#redirect_old_show_route', constraints: lambda{|req| req.params[:project_id] != 'new' }
      get 'embed', as: :old_embed
      get 'permissions/edit' => 'permissions#edit', as: :edit_permissions
      patch 'permissions' => 'permissions#update'
      get 'team/edit' => 'members#edit', as: :edit_team
      patch 'team' => 'members#update'
      patch 'guest_name' => 'members#update_guest_name'
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

    get 'projects/e/:user_name/:id' => 'projects#show_external', as: :external_project, id: /[0-9]+\-[A-Za-z0-9\-]+/
    get 'projects/e/:user_name/:slug' => 'projects#redirect_external', as: :external_project_redirect  # legacy route (google has indexed them)
    get 'get_xframe_options' => 'projects#get_xframe_options'

    resources :assignments, only: [] do
      get 'grades' => 'grades#index', as: :grades
      get 'grades/edit(/:project_id(/:user_id))' => 'grades#edit', as: :edit_grade
      post 'grades(/:project_id(/:user_id))' => 'grades#update', as: :grade
      patch 'grades(/:project_id(/:user_id))' => 'grades#update'
    end
    resources :grades, only: [:index]

    resources :issues, only: [] do
      resources :comments, only: [:create]
    end

    resources :blog_posts, only: [:destroy], controller: :build_logs do
      resources :comments, only: [:create]
    end
    resources :wiki_pages, only: [:destroy]

    resources :followers, only: [:create] do
      delete '' => 'followers#destroy', on: :collection
    end

    resources :hackers, controller: :users, only: [:index]

    get 'activity' => 'broadcasts#index'

    get 'users/registration/complete_profile' => 'users#after_registration', as: :user_after_registration
    patch 'users/registration/complete_profile' => 'users#after_registration_save'


    get 'contact' => 'contact#new'
    post 'contact' => 'contact#create'

    get 'about' => 'pages#about'
    # get 'help' => 'pages#help'
    get 'home', to: redirect('/')
    # get 'me', to: 'users#me'

    get 'ping' => 'pages#ping'  # for availability monitoring
    get 'obscure/path/to/cron' => 'cron#run'

    get 'profile/edit' => 'users#edit'
    patch 'profile' => 'users#update'

    get 'search' => 'search#search'
    get 'tags/:tag' => 'search#tags', as: :tags
    get 'tags' => 'search#tags'
    get 'tools' => 'teches#index'

    get 'infringement_policy' => 'pages#infringement_policy'
    get 'privacy' => 'pages#privacy'
    get 'terms' => 'pages#terms'
    get 'resources' => 'pages#resources'

    get 'electric-imp', to: redirect('electricimp')

    # get ':slug' => 'slugs#show', slug: /[A-Za-z0-9_]{3,}/, constraints: { format: /(html|json)/ }
    constraints(TechPage) do
      get ':slug' => 'teches#show', slug: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json)/ }
      get ':slug/embed' => 'teches#embed', slug: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json)/ }
      get ':user_name' => 'teches#show', as: :tech_short, user_name: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json)/ }
    end
    constraints(UserPage) do
      get ':slug' => 'users#show', slug: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json)/ }
      get ':user_name' => 'users#show', as: :user, user_name: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json)/ }
    end

    scope ':user_name/:project_slug', as: :project, user_name: /[A-Za-z0-9_\-]{3,}/, project_slug: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json|js)/ } do
      get '' => 'projects#show', as: ''
      delete '' => 'projects#destroy'
      patch '' => 'projects#update'
      get 'embed' => 'projects#embed', as: :embed
      resources :issues do
        patch 'update_workflow', on: :member
      end
      resources :logs, controller: :build_logs
    end

    get ':not_found' => 'application#not_found'  # find a way to not need this

    root to: 'pages#home'
  end

  constraints(ClientSite) do
    scope module: :client, as: :client do

      get 'search' => 'search#search'

      # get ':user_name' => 'users#show', as: :user, user_name: /[A-Za-z0-9_]{3,}/, constraints: { format: /(html|json)/ }

      # scope ':user_name/:project_slug', as: :project, user_name: /[A-Za-z0-9_]{3,}/, project_slug: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json|js)/ } do
      #   get '' => 'projects#show', as: ''
      # end

      root to: 'projects#index'
    end
  end
end
