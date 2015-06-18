require 'route_constraints'
require 'sidekiq/web'

HackerIo::Application.routes.draw do

  constraints subdomain: /beta/ do
    match '(*any)' => redirect { |params, request|
      URI.parse(request.url).tap { |uri| uri.host.sub!(/^beta\./i, 'www.') }.to_s
    }, via: :get
  end

  # API (see if can be moved to its own subdomain)
  namespace :api do
    namespace :v1 do
      get 'embeds' => 'embeds#show'
      # post 'embeds' => 'embeds#create'
      resources :announcements
      resources :build_logs
      resources :code_files, only: [:create]
      resources :comments, only: [:create, :destroy]
      resources :likes, only: [:create] do
        delete '' => 'likes#destroy', on: :collection
      end
      resources :projects#, as: :api_projects
      resources :parts, only: [:create, :destroy] do
        get :autocomplete, on: :collection
      end
      scope 'platforms' do
        get ':user_name' => 'platforms#show'
        scope ':user_name' do
          get 'analytics' => 'platforms#analytics', defaults: { format: :json }
        end
      end
      resources :microsoft_chrome_sync, only: [] do
        get '' => 'microsoft_chrome_sync#show', on: :collection
        patch '' => 'microsoft_chrome_sync#update', on: :collection
      end
      resources :thoughts
      resources :users, only: [] do
        get :autocomplete, on: :collection
      end
      resources :widgets, only: [:destroy, :update, :create]
      match "*all" => "base#cors_preflight_check", via: :options
    end
  end

  # constraints(ApiSite) do
  # end

  devise_for :users, skip: [:session, :password, :registration, :confirmation, :invitation], controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  scope '(:locale)', locale: /[a-z]{2}(-[A-Z]{2})?/ do
    constraints(MainSite) do
      get 'sitemap_index.xml' => 'sitemap#index', as: 'sitemap_index', defaults: { format: 'xml' }
      get 'sitemap.xml' => 'sitemap#show', as: 'sitemap', defaults: { format: 'xml' }

      # api for split a/b testing gem
      get 'ab_test' => 'split#start_ab_test'
      # post 'finished' => 'split#finished_test'
      # get 'finish_and_redirect' => 'split#finish_and_redirect'
      # get 'validate_step' => 'split#validate_step'

      # get 'experts', to: redirect('/build')
      # get 'build' => 'expert_requests#new'
      # resources :expert_requests, only: [:create]
      post 'info_requests' => 'pages#create_info_request'

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
        get 'followers' => 'pages#followers'
        get 'hacker_spaces' => 'pages#hacker_spaces'
        get 'issues' => 'pages#issues'
        get 'logs' => 'pages#logs'
        get 'messages' => 'pages#messages'
        get 'newsletter' => 'pages#newsletter'
        post 'newsletter' => 'pages#newsletter'
        get 'platforms' => 'pages#platforms'
        get 'platforms/contacts' => 'pages#platform_contacts'
        get 'respects' => 'pages#respects'
        delete 'sidekiq/failures' => 'pages#clear_sidekiq_failures'

        resources :awarded_badges, only: [:create], controller: 'badges'
        resources :badges, except: [:show, :create]
        resources :blog_posts, except: [:show]
        resources :challenges, except: [:show]
        resources :conversations, only: [:destroy]
        resources :groups, except: [:show]
        resources :invitations, only: [:new, :create]
        resources :parts, except: [:show] do
          get 'duplicates' => 'parts#duplicates', as: 'duplicates', on: :collection
          get 'merge/new' => 'parts#merge_new', as: 'merge_new', on: :collection
          post 'merge' => 'parts#update', as: 'merge_into', on: :collection
        end
        resources :payments, except: [:show] do
          patch 'update_workflow' => 'payments#update_workflow', on: :member
        end
        resources :projects, except: [:show]
        resources :users, except: [:show]

        get 'store' => 'pages#store'
        namespace :store do
          resources :orders
          resources :products
        end
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

      scope :users, module: :users do
        resources :addresses, except: [:show, :edit]
      end

      namespace :store do
        get '' => 'products#index', as: ''
        resources :orders, only: [:index, :show, :update] do
          patch 'confirm' => 'orders#confirm', on: :collection
        end
        resources :order_lines, as: :cart, path: :cart, only: [:index, :create, :destroy]
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

      get 'lists/:user_name' => 'lists#show', as: :list
      match 'l/:user_name' => redirect { |params, request|
        URI.parse(request.url).tap { |uri| uri.path.sub!(/\/l\//i, '/lists/') }.to_s
      }, via: :get
      scope 'lists/:user_name', as: :lists do
        get '' => 'lists#show'
        patch '' => 'lists#update'
        post 'projects/link' => 'groups/projects#link'
        delete 'projects/link' => 'groups/projects#unlink'
      end
      resources :lists, except: [:show, :update] do
        resources :projects, only: [] do
          post 'feature' => 'lists#feature_project'#, as: :platform_feature_project
          delete 'feature' => 'lists#unfeature_project'
        end
      end

      resources :platforms, except: [:show] do
        get 'create' => 'platforms#create', on: :collection, as: :create
        get ':tag' => 'platforms#index', on: :collection, as: :tag, constraints: lambda{|req| req.params[:tag] != 'new' }
        resources :projects, only: [] do
          post 'feature' => 'platforms#feature_project'#, as: :platform_feature_project
          delete 'feature' => 'platforms#unfeature_project'
        end
      end
      resources :groups, only: [] do
        resources :products, controller: 'groups/parts'
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
        delete '' => 'hackathons#destroy'
        patch '' => 'hackathons#update'
        get 'events/new' => 'events#new', as: :new_event
        post 'events' => 'events#create', as: :events
        resources :pages, except: [:index, :show, :destroy], controller: 'wiki_pages'
        get 'pages/:slug' => 'wiki_pages#show'
        get 'organizers' => 'hackathons#organizers'
        get 'schedule/edit' => 'hackathons#edit_schedule'

        scope ':event_name', as: :event do
          get '' => 'events#show', as: ''
          delete '' => 'events#destroy'
          patch '' => 'events#update'
          resources :projects, only: [:new, :create], controller: 'groups/projects'
          patch 'projects/link' => 'groups/projects#link'
          resources :pages, except: [:index, :show, :destroy], controller: 'wiki_pages'
          get 'pages/:slug' => 'wiki_pages#show'
          get 'info' => 'events#info'
          get 'participants' => 'events#participants'
          get 'projects' => 'events#projects'
          get 'organizers' => 'events#organizers'
          get 'embed' => 'events#embed'
          get 'schedule/edit' => 'events#edit_schedule'
          get 'admin/participants' => 'events#participants_list', as: :participants_list
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

      scope 'followers' do
        get 'tools/:id' => 'followers#standalone_button', as: :followers_tool
        post 'tools/:id' => 'followers#create_from_button', as: :followers_create_tool
        get 'platforms/:id' => 'followers#standalone_button', as: :followers_platform
        post 'platforms/:id' => 'followers#create_from_button', as: :followers_create_platform
      end

      resources :project_collections, only: [:edit, :update]

      get 'hackers' => 'users#index', as: :hackers
      get 'hackers/:id' => 'users#redirect_to_show', as: :hacker, format: /(html|js)/

      scope 'challenges/:slug', as: :challenge do
        get '' => 'challenges#show'
        get 'brief' => 'challenges#brief'
        get 'projects' => 'challenges#projects'
        patch '' => 'challenges#update'
      end
      # get 'challenges/:slug' => 'challenges#show', as: :challenge
      resources :challenges, except: [:show, :update] do
        resources :entries, controller: :challenge_entries do
          get 'address/edit' => 'addresses#edit', on: :member, as: :edit_address
          patch 'address' => 'addresses#update', on: :member
        end
        post 'projects' => 'challenges#enter', on: :member, as: :enter
        post 'unlock' => 'challenges#unlock', on: :member
        put 'update_workflow' => 'challenges#update_workflow', on: :member
      end

      # resources :skill_requests, path: 'cupidon' do
      #   resources :comments, only: [:create]
      # end

      resources :notifications, only: [:index] do
        get 'edit' => 'notifications#edit', on: :collection
        patch 'edit' => 'notifications#update', on: :collection
      end

      resources :projects, only: [:index]

      # dragon
      get 'partners' => 'partners#index'
      get 'dragon/leads/new' => 'dragon_queries#new'
      post 'dragon/leads' => 'dragon_queries#create'

      get 'ping' => 'pages#ping'  # for availability monitoring
      get 'obscure/path/to/cron' => 'cron#run'

      get 'search' => 'search#search'
      get 'tools', to: redirect('platforms')
      get 'platforms' => 'platforms#index'

      get 'talk' => 'channels#show'
      get 'talk/*all' => 'channels#show'

      get 'csrf' => 'pages#csrf'

      get 'hardwareweekend' => 'pages#hardwareweekend'
      get 'hhw', to: redirect('/hardwareweekend')
      get 'hww', to: redirect('/hardwareweekend')
      get 'hweekend', to: redirect('/hardwareweekend')
      get 'roadshow', to: redirect('/hardwareweekend')
      get 'seattle', to: redirect('/hackathons/hardware-weekend/seattle')
      get 'portland', to: redirect('/hackathons/hardware-weekend/portland')
      get 'sf', to: redirect('/hackathons/hardware-weekend/san-francisco')
      get 'la', to: redirect('/hackathons/hardware-weekend/los-angeles')
      get 'phoenix', to: redirect('/hackathons/hardware-weekend/phoenix')
      get 'louisville', to: redirect('/hackathons/hardware-weekend/louisville')
      get 'dallas', to: redirect('/hackathons/hardware-weekend/dallas')
      get 'boston', to: redirect('/hackathons/hardware-weekend/boston')
      get 'brooklyn', to: redirect('/hackathons/hardware-weekend/brooklyn')
      get 'washington', to: redirect('/hackathons/hardware-weekend/washington')
      get 'nyc', to: redirect('/hackathons/hardware-weekend/new-york-city')

      get 'tinyduino', to: redirect('/tinycircuits')
      get 'spark', to: redirect('/particle')
      get 'spark/projects', to: redirect('/particle/projects')
      get 'spark/makes', to: redirect('/particle/components')
      get 'spark/makes/spark-core', to: redirect('/particle/components/spark-core')

      get 'home' => 'pages#home'
      get 'about' => 'pages#about'
      get 'business' => 'pages#business'
      # get 'help' => 'pages#help'
      get 'achievements' => 'pages#achievements'
      get 'home', to: redirect('/')
      get 'infringement_policy' => 'pages#infringement_policy'
      get 'privacy' => 'pages#privacy'
      get 'terms' => 'pages#terms'
      get 'press' => 'pages#press'
      get 'jobs' => 'pages#jobs'
      get 'resources' => 'pages#resources'

      # updates counter for cached pages
      get 'users/stats' => 'stats#index'
      post 'stats' => 'stats#create'
      post 'projects/:id/views' => 'stats#legacy'

      post 'chats/:group_id' => 'chat_messages#create', as: :chat_messages
      post 'chats/:group_id/slack' => 'chat_messages#incoming_slack'
      get 'users/slack_settings' => 'chat_messages#slack_settings', as: :user_slack_settings
      post 'users/slack_settings' => 'chat_messages#save_slack_settings'

      get 'business/payments/:safe_id' => 'payments#show', as: :payment
      post 'business/payments' => 'payments#create', as: :payments

      constraints(PlatformPage) do
        get ':slug' => 'platforms#show', as: :platform_home, slug: /[A-Za-z0-9_\-]{3,}/
        get ':user_name' => redirect('%{slug}/projects'), as: :platform_short, user_name: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json)/ }
        scope ':slug', slug: /[A-Za-z0-9_\-]{3,}/, as: :platform, constraints: { format: /(html|json|js|atom|rss)/ } do
          get 'analytics' => 'platforms#analytics'
          get 'chat' => 'chat_messages#index'
          resources :announcements, except: [:create, :update, :destroy], path: :news
          get 'embed' => 'platforms#embed'
          get 'products' => 'parts#index', as: :parts
          match 'makes/:part_slug' => redirect { |params, request|
            URI.parse(request.url).tap { |uri| uri.path.sub!(/makes/i, 'products') }.to_s
          }, via: :get
          # get 'components/third-party-made' => 'parts#sub_index', as: :sub_parts
          get 'products/:part_slug' => 'parts#show', as: :part
          get 'products/:part_slug/embed' => 'parts#embed', as: :embed_part
          get 'startups' => 'platforms#products', as: :products
          get 'projects' => 'platforms#projects', as: :projects
          get 'platforms' => 'platforms#sub_platforms', as: :sub_platforms
        end
      end

      # constraints(PartPage) do
      #   get ':slug' => 'platforms#show', slug: /[A-Za-z0-9_\-]{3,}/, constraints: { format: /(html|json|atom|rss)/ }
      # end

      # root to: 'pages#home'
    end

    devise_for :users, skip: :omniauth_callbacks, controllers: {
      confirmations: 'users/confirmations',
      invitations: 'users/invitations',
      omniauth_callbacks: 'users/omniauth_callbacks',
      registrations: 'users/registrations',
      sessions: 'users/sessions',
    }

    devise_scope :user do
      namespace :users, as: '' do
        resources :authorizations do
          get 'update' => 'authorizations#update', on: :collection, as: :update
        end
        get 'auth/:provider/setup' => 'omniauth_callbacks#setup'
        patch 'confirm' => 'confirmations#confirm'
        resources :simplified_registrations, only: [:create] do
          get 'create' => 'simplified_registrations#create', on: :collection, as: :create
        end
      end
    end

    get 'users/registration/complete_profile' => 'users#after_registration', as: :user_after_registration
    patch 'users/registration/complete_profile' => 'users#after_registration_save'

    resources :announcements, only: [:destroy] do
      resources :comments, only: [:create]
    end

    resources :comments, only: [:edit, :update, :destroy]

    resources :files, only: [:create, :show, :destroy] do
      get 'remote_upload' => 'files#check_remote_upload', on: :collection
      post 'remote_upload', on: :collection
      get 'signed_url', on: :collection
    end

    resources :projects, except: [:index, :show, :update, :destroy] do
      patch 'submit' => 'projects#submit', on: :member
      get 'settings' => 'external_projects#edit', on: :member
      patch 'settings' => 'external_projects#update', on: :member
      post 'claim' => 'projects#claim', on: :member
      get 'last' => 'projects#redirect_to_last', on: :collection
      get '' => 'projects#redirect_to_slug_route', constraints: lambda{|req| req.params[:project_id] =~ /[0-9]+/ }
      get 'embed', as: :old_embed
      get 'permissions/edit' => 'permissions#edit', as: :edit_permissions
      patch 'permissions' => 'permissions#update'
      get 'team/edit' => 'members#edit', as: :edit_team
      patch 'team' => 'members#update'
      patch 'guest_name' => 'members#update_guest_name'
      patch 'update_workflow' => 'projects#update_workflow', on: :member
      collection do
        resources :imports, only: [:new, :create], controller: :project_imports, as: :project_imports
      end
      resources :comments, only: [:create]
      resources :respects, only: [:create] do
        get 'create' => 'respects#create', on: :collection, as: :create
        delete '' => 'respects#destroy', on: :collection
      end
    end

    get 'projects/e/:user_name/:id' => 'external_projects#show', as: :external_project, id: /[0-9]+\-[A-Za-z0-9\-]+/
    delete 'projects/e/:user_name/:id' => 'projects#destroy', id: /[0-9]+\-[A-Za-z0-9\-]+/
    get 'projects/e/:user_name/:slug' => 'external_projects#redirect_to_show', as: :external_project_redirect  # legacy route (google has indexed them)

    get ':user_name/powers/:slug' => 'products#show', as: :product

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
        get 'create' => 'followers#create', as: :create
        delete '' => 'followers#destroy'
      end
    end

    get 'profile/edit' => 'users#edit'
    patch 'profile' => 'users#update'

    # get 'search' => 'search#search'
    get 'tags/:tag' => redirect('/projects/tags/%{tag}'), via: :get, as: :deprecated_tags
    get 'tags' => 'search#tags', as: :deprecated_tags2
    get 'projects/tags/:tag' => 'search#tags', as: :tags
    get 'projects/tags' => 'search#tags'
    get 'robots' => 'pages#robots'

    # get 'pdf_viewer' => 'pages#pdf_viewer'

    constraints(ClientSite) do
      resources :announcements, only: [:index, :show], path: :news, as: :whitelabel_announcement
      scope module: :client, as: :client do
        get 'products' => 'products#index'
        get 'products/:part_slug' => 'parts#show', as: :part
        get 'products/:part_slug/embed' => 'parts#embed', as: :embed_part

        get 'search' => 'search#search'
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
      get 'print' => 'projects#print', as: :print
      resources :issues do
        patch 'update_workflow', on: :member
      end
      resources :logs, controller: :build_logs
    end

    constraints(ClientSite) do
      scope module: :client, as: :client do
        get '' => 'projects#index'
        root to: 'projects#index'
      end
    end

    get '' => 'pages#home'
    root to: 'pages#home'
    get '*not_found' => 'application#not_found'  # find a way to not need this
  end
end