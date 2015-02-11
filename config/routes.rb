require 'route_constraints'
require 'sidekiq/web'

HackerIo::Application.routes.draw do

  constraints subdomain: /beta/ do
    match '(*any)' => redirect { |params, request|
      URI.parse(request.url).tap { |uri| uri.host.sub!(/^beta\./i, 'www.') }.to_s
    }, via: :get
  end

  # constraints(ApiSite) do
  # end

  constraints(MainSite) do
    get 'sitemap_index.xml' => 'sitemap#index', as: 'sitemap_index', defaults: { format: 'xml' }
    get 'sitemap.xml' => 'sitemap#show', as: 'sitemap', defaults: { format: 'xml' }

    # api for split a/b testing gem
    get 'ab_test' => 'split#start_ab_test'
    # post 'finished' => 'split#finished_test'
    # get 'finish_and_redirect' => 'split#finish_and_redirect'
    # get 'validate_step' => 'split#validate_step'

    get 'experts', to: redirect('/build')
    get 'build' => 'expert_requests#new'
    resources :expert_requests, only: [:create]

    post 'pusher/auth' => 'users/pusher_authentications#create'

    namespace :admin do
      authenticate :user, lambda { |u| u.is? :admin } do
        mount Sidekiq::Web => '/sidekiq'
        mount Split::Dashboard, :at => 'split'
      end
      get '', to: redirect('admin/analytics')
      get 'analytics' => 'pages#analytics'
      get 'build_logs' => 'pages#build_logs'
      get 'comments' => 'pages#comments'
      get 'hacker_spaces' => 'pages#hacker_spaces'
      get 'issues' => 'pages#issues'
      get 'logs' => 'pages#logs'
      get 'messages' => 'pages#messages'
      get 'respects' => 'pages#respects'
      get 'platforms' => 'pages#platforms'
      get 'followers' => 'pages#followers'
      delete 'sidekiq/failures' => 'pages#clear_sidekiq_failures'

      resources :awarded_badges, only: [:create], controller: 'badges'
      resources :badges, except: [:show, :create]
      resources :blog_posts, except: [:show]
      resources :groups, except: [:show]
      resources :parts, except: [:show] do
        get 'duplicates' => 'parts#duplicates', as: 'duplicates', on: :collection
        get 'merge/new' => 'parts#merge_new', as: 'merge_new', on: :collection
        post 'merge' => 'parts#update', as: 'merge_into', on: :collection
      end
      resources :projects, except: [:show]
      resources :users, except: [:show]

      root to: 'pages#root'
    end  # end admin

    namespace :spark do
      resources :authorizations, except: [:show, :edit, :update] do
        get 'current' => 'authorizations#show', on: :collection
        delete '' => 'authorizations#destroy', on: :collection
      end
      resources :uploads, only: [:new]
    end

    scope '/blog', module: :blog do
      get '' => 'posts#index', as: :blog_index
      get 'tags/:tag' => 'posts#index', as: :blog_tag
      get '*slug' => 'posts#show', as: :blog_post, slug: /[a-zA-Z0-9\-\/]+/
    end

    # groups
    resources :groups, only: [:edit, :update] do
      post 'members' => 'members#create', as: :members
      get 'members/edit' => 'members#edit', as: :edit_members
      patch 'members' => 'members#update'
      get 'invitations' => 'group_invitations#index', as: :invitations
      get 'invitations/new' => 'group_invitations#new', as: :new_invitations
      post 'invitations' => 'group_invitations#create'
      get 'invitations/accept' => 'group_invitations#accept', as: :accept_invitation
      get 'awards/edit' => 'grades#edit', as: :edit_awards
      patch 'awards' => 'grades#update'
      patch 'projects/link' => 'groups/projects#link'
      get 'projects' => 'groups/projects#index', as: :admin_projects
      patch 'projects/:id' => 'groups/projects#update_workflow', as: :update_workflow
    end

    get 'h/:user_name' => 'hacker_spaces#redirect_to_show'
    resources :hacker_spaces, except: [:show, :update], path: 'hackerspaces'
    scope 'hackerspaces/:user_name', as: :hacker_space do
      get '' => 'hacker_spaces#show'
      patch '' => 'hacker_spaces#update'
      resources :projects, only: [:new, :create], controller: 'groups/projects'
      patch 'projects/link' => 'groups/projects#link'
    end
    post 'claims' => 'claims#create'

    resources :members, only: [] do
      patch 'process' => 'members#process_request'
    end

    get 'c/:user_name' => 'communities#redirect_to_show'
    resources :communities, except: [:show, :update]
    scope 'communities/:user_name', as: :communities do
      get '' => 'communities#show'
      patch '' => 'communities#update'
      resources :projects, only: [:new, :create], controller: 'groups/projects'
      patch 'projects/link' => 'groups/projects#link'
    end

    get 'l/:user_name' => 'lists#show', as: :list
    match 'lists/:user_name' => redirect { |params, request|
      URI.parse(request.url).tap { |uri| uri.path.sub!(/lists/i, 'l') }.to_s
    }, via: :get
    scope 'l/:user_name', as: :lists do
      get '' => 'lists#show'
      patch '' => 'lists#update'
      post 'projects/link' => 'groups/projects#link'
      delete 'projects/link' => 'groups/projects#unlink'
    end
    resources :lists, except: [:show, :update], path: 'l' do
      resources :projects, only: [] do
        post 'feature' => 'lists#feature_project'#, as: :platform_feature_project
        delete 'feature' => 'lists#unfeature_project'
      end
    end

    resources :platforms, except: [:show] do
      resources :projects, only: [] do
        post 'feature' => 'platforms#feature_project'#, as: :platform_feature_project
        delete 'feature' => 'platforms#unfeature_project'
      end
    end
    resources :groups, only: [] do
      resources :parts, controller: 'groups/parts'
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
    # end groups

    resources :assignments, only: [] do
      get 'grades' => 'grades#index', as: :grades
      get 'grades/edit(/:project_id(/:user_id))' => 'grades#edit', as: :edit_grade
      post 'grades(/:project_id(/:user_id))' => 'grades#update', as: :grade
      patch 'grades(/:project_id(/:user_id))' => 'grades#update'
    end
    resources :grades, only: [:index]

    resources :wiki_pages, only: [:destroy]

    resources :announcements, only: [:destroy] do
      resources :comments, only: [:create]
    end

    namespace 'followers' do
      get 'tools/:id' => 'followers#standalone_button', as: :tool
      post 'tools/:id' => 'followers#create_from_button', as: :create_tool
      get 'platforms/:id' => 'followers#standalone_button', as: :platform
      post 'platforms/:id' => 'followers#create_from_button', as: :create_platform
    end

    resources :project_collections, only: [:edit, :update]

    get 'hackers' => 'users#index', as: :hackers
    get 'hackers/:id' => 'users#redirect_to_show', as: :hacker

    scope 'challenges/:slug', as: :challenge do
      get '' => 'challenges#show'
      get 'rules' => 'challenges#rules'
      patch '' => 'challenges#update'
    end
    # get 'challenges/:slug' => 'challenges#show', as: :challenge
    resources :challenges, except: [:show, :update] do
      resources :entries, controller: :challenge_entries do
        get 'address/edit' => 'addresses#edit', on: :member, as: :edit_address
        patch 'address' => 'addresses#update', on: :member
      end
      post 'projects' => 'challenges#enter', on: :member, as: :enter
      put 'update_workflow' => 'challenges#update_workflow', on: :member
    end

    resources :skill_requests, path: 'cupidon' do
      resources :comments, only: [:create]
    end

    # dragon
    get 'partners' => 'partners#index'
    get 'dragon/leads/new' => 'dragon_queries#new'
    post 'dragon/leads' => 'dragon_queries#create'

    get 'ping' => 'pages#ping'  # for availability monitoring
    get 'obscure/path/to/cron' => 'cron#run'

    # get 'profile/edit' => 'users#edit'
    # patch 'profile' => 'users#update'

    get 'search' => 'search#search'
    # get 'tags/:tag' => 'search#tags', as: :tags
    # get 'tags' => 'search#tags'
    get 'tools', to: redirect('platforms')
    get 'platforms' => 'platforms#index'

    get 'hardwareweekend' => 'pages#hardwareweekend'
    get 'hhw', to: redirect('/hardwareweekend')
    get 'hww', to: redirect('/hardwareweekend')
    get 'hweekend', to: redirect('/hardwareweekend')
    get 'roadshow', to: redirect('/hardwareweekend')

    get 'tinyduino', to: redirect('/tinycircuits')

    get 'about' => 'pages#about'
    # get 'help' => 'pages#help'
    get 'achievements' => 'pages#achievements'
    get 'home', to: redirect('/')
    get 'infringement_policy' => 'pages#infringement_policy'
    get 'privacy' => 'pages#privacy'
    get 'terms' => 'pages#terms'
    get 'press' => 'pages#press'
    get 'jobs' => 'pages#jobs'
    get 'resources' => 'pages#resources'

    post 'chats/:group_id' => 'chat_messages#create', as: :chat_messages
    post 'chats/:group_id/slack' => 'chat_messages#incoming_slack'
    get 'users/slack_settings' => 'chat_messages#slack_settings', as: :user_slack_settings
    post 'users/slack_settings' => 'chat_messages#save_slack_settings'

    constraints(PlatformPage) do
      get ':slug' => 'platforms#show', slug: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json|atom|rss)/ }
      get ':slug/embed' => 'platforms#embed', slug: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json)/ }
      get ':user_name' => 'platforms#show', as: :platform_short, user_name: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json)/ }
      scope ':slug', slug: /[A-Za-z0-9_\-]{3,}/, as: :platform, constraints: { format: /(html|json)/ } do
        get 'analytics' => 'platforms#analytics'
        get 'chat' => 'chat_messages#index'
        resources :announcements, except: [:create, :update, :destroy], path: :news
        get 'parts' => 'parts#index'
        get ':part_slug' => 'parts#show', as: :part
        get ':part_slug/embed' => 'parts#embed', as: :embed_part
      end
    end

    # constraints(PartPage) do
    #   get ':slug' => 'platforms#show', slug: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json|atom|rss)/ }
    # end

    root to: 'pages#home'
  end

  # API (see if can be moved to its own subdomain)
  namespace :api do
    namespace :v1 do
      get 'embeds' => 'embeds#show'
      # post 'embeds' => 'embeds#create'
      resources :announcements
      resources :build_logs
      resources :projects#, as: :api_projects
      resources :parts, only: [:create, :destroy] do
        get :autocomplete, on: :collection
      end
      resources :platforms, only: [:show]
      resources :users, only: [] do
        get :autocomplete, on: :collection
      end
      resources :widgets, only: [:destroy, :update, :create]
      match "*all" => "base#cors_preflight_check", via: :options
    end
  end

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    invitations: 'users/invitations',
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions',
    registrations: 'users/registrations',
  }

  devise_scope :user do
    namespace :users, as: '' do
      patch '/confirm' => 'confirmations#confirm'
      resources :authorizations
      match '/auth/:provider/setup' => 'omniauth_callbacks#setup', via: :get
      resources :simplified_registrations, only: [:create]
    end
  end

  resources :comments, only: [:edit, :update, :destroy]

  resources :files, only: [:create, :show, :destroy] do
    get 'remote_upload' => 'files#check_remote_upload', on: :collection
    post 'remote_upload', on: :collection
    get 'signed_url', on: :collection
  end
  delete 'notifications' => 'notifications#destroy'

  resources :projects, except: [:show, :update, :destroy] do
    patch 'submit' => 'projects#submit', on: :member
    get 'settings' => 'projects#settings', on: :member
    patch 'settings' => 'projects#update', on: :member
    post 'claim' => 'projects#claim', on: :member
    get 'last' => 'projects#redirect_to_last', on: :collection
    get '' => 'projects#redirect_to_slug_route', constraints: lambda{|req| req.params[:project_id] != 'new' }
    get 'embed', as: :old_embed
    get 'permissions/edit' => 'permissions#edit', as: :edit_permissions
    patch 'permissions' => 'permissions#update'
    get 'team/edit' => 'members#edit', as: :edit_team
    patch 'team' => 'members#update'
    patch 'guest_name' => 'members#update_guest_name'
    collection do
      resources :imports, only: [:new, :create], controller: :project_imports, as: :project_imports
    end
    resources :comments, only: [:create]
    resources :respects, only: [:create] do
      get 'create' => 'respects#create', on: :collection, as: :create
      delete '' => 'respects#destroy', on: :collection
    end
  end

  get 'projects/e/:user_name/:id' => 'projects#show_external', as: :external_project, id: /[0-9]+\-[A-Za-z0-9\-]+/
  delete 'projects/e/:user_name/:id' => 'projects#destroy', id: /[0-9]+\-[A-Za-z0-9\-]+/
  get 'projects/e/:user_name/:slug' => 'projects#redirect_external', as: :external_project_redirect  # legacy route (google has indexed them)

  resources :issues, only: [] do
    resources :comments, only: [:create]
  end

  resources :build_logs, only: [:destroy] do
    get '' => 'build_logs#show_redirect', on: :member
    resources :comments, only: [:create]
  end

  resources :messages, as: :conversations, controller: :conversations

  resources :followers, only: [:create] do
    collection do
      # post '' => 'followers#create', as: ''
      get 'create' => 'followers#create', as: :create
      delete '' => 'followers#destroy'
    end
  end

  get 'users/registration/complete_profile' => 'users#after_registration', as: :user_after_registration
  patch 'users/registration/complete_profile' => 'users#after_registration_save'

  get 'profile/edit' => 'users#edit'
  patch 'profile' => 'users#update'

  # get 'search' => 'search#search'
  get 'tags/:tag' => 'search#tags', as: :tags
  get 'tags' => 'search#tags'

  constraints(ClientSite) do
    scope module: :client, as: :client do
      get 'parts' => 'parts#index'
      get ':part_slug' => 'parts#show', as: :part
      get ':part_slug/embed' => 'parts#embed', as: :embed_part
    end
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

  constraints(ClientSite) do
    scope module: :client, as: :client do
      get 'search' => 'search#search'

      root to: 'projects#index'
    end
  end

  get '*not_found' => 'application#not_found'  # find a way to not need this
end
