require 'route_constraints'
require 'sidekiq/web'
require 'sidekiq/cron/web'

HackerIo::Application.routes.draw do
  constraints(IntelLandingPage) do
    get '/' => 'landing_pages#intel'
  end

  constraints(MouserContest) do
    scope module: :mouser, as: :mouser do
      scope module: :api, as: :api do
        resources :phases, only: [:update]
        resources :projects, only: [:index]
        resources :submissions, only: [:index, :create] do
          patch 'workflow' => 'submissions#update_workflow', on: :member
        end
        match "*all" => "base#cors_preflight_check", via: :options
      end

      get '/' => 'vendors#index', as: :vendors
      get 'admin' => 'vendors#index', as: :admin
      get ':user_name' => 'vendors#show', as: :vendor
    end
  end

  constraints(ShortLinkDomain) do
    get ':slug' => 'short_links#show'
    get '/' => redirect('https://www.hackster.io')
  end

  constraints(NotShortLinkDomain) do
    constraints subdomain: /beta/ do
      match '(*any)' => redirect { |params, request|
        URI.parse(request.url).tap { |uri| uri.host.sub!(/^beta\./i, 'www.') }.to_s
      }, via: :get
    end

    constraints(ApiSite) do
      scope module: :api, as: :api, defaults: { format: :json } do
        # this stuff is authenticated with cookies
        namespace :private do
          get 'csrf' => 'pages#csrf'
          get 'embeds' => 'embeds#show'
          resources :announcements
          resources :build_logs
          resources :challenges, only: [] do
            get 'entries_csv' => 'challenges#entries_csv'
            get 'ideas_csv' => 'challenges#ideas_csv'
            get 'participants_csv' => 'challenges#participants_csv'
          end
          resources :challenge_registrations do
            patch '' => 'challenge_registrations#update', on: :collection
          end
          resources :error_logs
          resources :files, only: [:create, :show, :destroy] do
            get 'remote_upload' => 'files#check_remote_upload', on: :collection, as: :remote_upload
            post 'remote_upload', on: :collection
            get 'signed_url', on: :collection, as: :signed_url
          end
          resources :flags, only: [:create]
          resources :followers, only: [:create, :index] do
            collection do
              delete '' => 'followers#destroy'
            end
          end
          resources :groups, only: [:index, :create]
          resources :notifications, only: [:index]
          resources :stats, only: [:create]
          resources :thoughts
          resources :users, only: [:index]
          resources :widgets, only: [:destroy, :update, :create]
          match "*all" => "base#cors_preflight_check", via: :options
        end

        # this stuff is authenticated with tokens from doorkeeper
        namespace :private, module: 'private_doorkeeper' do
          get 'me' => 'users#show'
          resources :jobs, only: [:create, :show]
          resources :projects, only: [] do
            get 'description' => 'projects#description', on: :member
          end
          scope :review_decisions do
            post '' => 'review_decisions#create'
          end
          scope :review_threads do
            get '' => 'review_threads#show'
          end
          resources :users, only: [] do
            get :autocomplete, on: :collection
          end
          match "*all" => "base#cors_preflight_check", via: :options
        end

        namespace :v1 do
          resources :chrome_sync, only: [] do
            get '' => 'chrome_sync#show', on: :collection
            patch '' => 'chrome_sync#update', on: :collection
          end
          resources :challenges, only: [:index]
          resources :parts, except: [:new, :edit]
          scope :platforms do
            scope :analytics do
              get '' => 'platform_analytics#show'
              get 'projects' => 'platform_analytics#projects'
            end
            get ':user_name' => 'platforms#show'
          end
          resources :projects, only: [:show, :index]
          resources :users, only: [:show]
          get 'search' => 'search#index'
          match "*all" => "base#cors_preflight_check", via: :options
        end

        namespace :v2 do
          get 'me' => 'users#me'
          resources :comments, only: [:index, :create, :update, :destroy]
          resources :likes, only: [:create] do
            delete '' => 'likes#destroy', on: :collection
          end
          resources :lists, only: [:index, :create] do
            post 'projects' => 'lists#link_project', on: :member
            delete 'projects' => 'lists#unlink_project', on: :member
          end
          resources :parts, except: [:new, :edit]
          resources :projects, except: [:show, :index]
          match "*all" => "base#cors_preflight_check", via: :options
        end
      end
    end

    constraints(NotApiSite) do

      devise_for :users, skip: [:session, :password, :registration, :confirmation, :invitation], controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

      constraints(MainSite) do
        use_doorkeeper do
          controllers applications: 'users/oauth/applications'
        end

        # get 'test' => 'pages#test'
        get 'sitemap_index.xml' => 'sitemap#index', as: 'sitemap_index', defaults: { format: 'xml' }
        get 'sitemap.xml' => 'sitemap#show', as: 'sitemap', defaults: { format: 'xml' }

        # api for split a/b testing gem
        get 'ab_test' => 'split#start_ab_test'
        # post 'finished' => 'split#finished_test'
        get 'finish_and_redirect' => 'split#finish_and_redirect'
        # get 'validate_step' => 'split#validate_step'

        post 'info_requests' => 'pages#create_info_request'
        post 'pusher/auth' => 'users/pusher_authentications#create'
        get 'hello_world' => 'hello_world#show'

        namespace :admin do
          authenticate :user, lambda { |u| u.is? :admin } do
            mount Sidekiq::Web => '/sidekiq'
            mount Split::Dashboard, :at => 'split'
          end
          get '' => 'pages#home', as: :home
          get 'analytics' => 'pages#analytics'
          get 'build_logs' => 'pages#build_logs'
          get 'comments' => 'pages#comments'
          get 'followers' => 'pages#followers'
          get 'hacker_spaces' => 'pages#hacker_spaces'
          get 'issues' => 'pages#issues'
          get 'lists' => 'pages#lists'
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
          resources :jobs, except: [:show]
          resources :meetups, except: [:show]
          resources :parts, except: [:show] do
            get 'duplicates' => 'parts#duplicates', as: 'duplicates', on: :collection
            get 'merge/new' => 'parts#merge_new', as: 'merge_new', on: :collection
            post 'merge' => 'parts#update', as: 'merge_into', on: :collection
          end
          resources :payments, except: [:show] do
            patch 'update_workflow' => 'payments#update_workflow', on: :member
          end
          resources :projects, except: [:show]
          resources :short_links, except: [:show]
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
            match 'confirm' => 'orders#confirm', on: :collection, via: [:get, :patch]
          end
          resources :order_lines, as: :cart, path: :cart, only: [:index, :create, :destroy]
        end

        # groups
        resources :groups, only: [:show, :edit, :update, :destroy] do
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
          get 'projects/featured' => 'groups/projects#featured'
          patch 'projects/featured' => 'groups/projects#save_featured'
          patch 'projects/:id' => 'groups/projects#update_workflow', as: :update_workflow
          patch 'projects/:id/certificate' => 'groups/projects#update_certificate', as: :update_certificate
        end

        # get 'h/:user_name' => 'hacker_spaces#redirect_to_show'
        resources :hacker_spaces, except: [:show, :update], path: 'hackerspaces' do
          get 'create' => 'hacker_spaces#create', on: :collection, as: :create
        end
        scope 'hackerspaces/:user_name', as: :hacker_space do
          get '' => 'hacker_spaces#show'
          patch '' => 'hacker_spaces#update'
          resources :projects, only: [:new, :create], controller: 'groups/projects'
          patch 'projects/link' => 'groups/projects#link'
        end
        post 'claims' => 'claims#create'

        resources :members, only: [:destroy] do
          patch 'process' => 'members#process_request'
        end

        # get 'c/:user_name' => 'communities#redirect_to_show'
        resources :communities, except: [:show, :update]
        scope 'communities/:user_name', as: :communities do
          get '' => 'communities#show'
          patch '' => 'communities#update'
          resources :projects, only: [:new, :create], controller: 'groups/projects'
          patch 'projects/link' => 'groups/projects#link'
        end

        match 'l/:user_name' => redirect { |params, request|
          URI.parse(request.url).tap { |uri| uri.path.sub!(/\/l\//i, '/lists/') }.to_s
        }, via: :get
        resources :lists, except: [:show, :update] do
          get 'create' => 'lists#create', on: :collection, as: :create
          resources :projects, only: [] do
            post 'feature' => 'lists#feature_project'#, as: :platform_feature_project
            delete 'feature' => 'lists#unfeature_project'
          end
        end
        get 'lists/:user_name' => 'lists#show'#, as: :list
        scope 'lists/:user_name', as: :lists do
          patch '' => 'lists#update'
          post 'projects/link' => 'groups/projects#link'
          delete 'projects/link' => 'groups/projects#unlink'
        end

        resources :platforms, except: [:show] do
          get 'create' => 'platforms#create', on: :collection, as: :create
          get 'incubator' => 'platforms#incubator', on: :collection, as: :incubator
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
          patch '' => 'courses#update'

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
        get 'courses/new' => 'courses#new', as: :new_course
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

        get 'live' => 'meetups#index'
        get 'live/new' => 'meetups#new', as: :new_meetup
        post 'live/chapters' => 'meetups#create', as: :meetups
        scope 'live/:user_name', as: :meetup do
          get '' => 'meetups#show', as: ''
          delete '' => 'meetups#destroy'
          patch '' => 'meetups#update'
          # resources :pages, except: [:index, :show, :destroy], controller: 'wiki_pages'
          # get 'pages/:slug' => 'wiki_pages#show'

          resources :events, controller: 'meetup_events' do
            resources :projects, only: [:new, :create], controller: 'groups/projects'
            patch 'projects/link' => 'groups/projects#link'
            # resources :pages, except: [:index, :show, :destroy], controller: 'wiki_pages'
            # get 'pages/:slug' => 'wiki_pages#show'
            get 'embed' => 'meetup_events#embed'
            get 'admin/participants' => 'meetup_events#participants_list', as: :participants_list
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

        get 'events/:id/export' => 'events#export', as: :export_event

        resources :wiki_pages, only: [:destroy]

        scope 'followers' do
          get 'tools/:id' => 'followers#standalone_button', as: :followers_tool
          post 'tools/:id' => 'followers#create_from_button', as: :followers_create_tool
          get 'platforms/:id' => 'followers#standalone_button', as: :followers_platform
          post 'platforms/:id' => 'followers#create_from_button', as: :followers_create_platform
        end

        resources :project_collections, only: [:edit, :update]

        scope 'challenges/:slug', as: :challenge do
          get '' => 'challenges#show'
          get 'brief' => 'challenges#brief'
          get 'participants' => 'challenges#participants'
          get 'projects' => 'challenges#projects'
          patch '' => 'challenges#update'
          resources :ideas, controller: :challenge_ideas, only: [:new, :create, :edit, :update]
          get 'ideas' => 'challenges#ideas'
          get 'ideas/winners' => 'challenges#idea_winners', as: :idea_winners
          get 'ideas/:id' => 'challenges#idea'
          get 'faq' => 'challenges#faq'
        end

        resources :challenges, except: [:show, :update] do
          get 'admin/dashboard' => 'challenges#dashboard', as: :admin
          resources :entries, controller: :challenge_entries, only: [:index, :new], path: 'admin/entries', as: :admin_entries
          resources :ideas, controller: :challenge_ideas, only: [:index], path: 'admin/ideas', as: :admin_ideas
          resources :entries, controller: :challenge_entries, only: [:create, :edit, :update, :destroy] do
            put 'update_workflow' => 'challenge_entries#update_workflow', on: :member
            get 'address/edit' => 'addresses#edit', on: :member, as: :edit_address
            patch 'address' => 'addresses#update', on: :member
          end
          resources :faq_entries, except: [:show, :destroy]
          resources :ideas, controller: :challenge_ideas, only: [] do
            put 'update_workflow' => 'challenge_ideas#update_workflow', on: :member
          end
          resources :registrations, controller: :challenge_registrations, only: [:create] do
            delete '' => 'challenge_registrations#destroy', on: :collection
            get 'create' => 'challenge_registrations#create', on: :collection, as: :create
          end
          post 'projects' => 'challenges#enter', on: :member, as: :enter
          post 'unlock' => 'challenges#unlock', on: :member
          put 'update_workflow' => 'challenges#update_workflow', on: :member
          patch 'update_mailchimp' => 'challenges#update_mailchimp', on: :member
        end

        resources :faq_entries, only: [:destroy]

        resources :challenge_entries, only: [], as: :challenge_single_entry do
          resources :respects, only: [:create], controller: 'votes' do
            get 'create' => 'votes#create', on: :collection, as: :create
            delete '' => 'votes#destroy', on: :collection
          end
        end

        resources :challenge_ideas, only: [:update, :destroy], as: :challenge_single_idea

        # resources :skill_requests, path: 'cupidon' do
        #   resources :comments, only: [:create]
        # end

        get 's/:slug' => 'short_links#show'

        scope 'sparkfun/wishlists', as: :sparkfun_wishlists do
          resources :imports, only: [:new, :create], controller: 'sparkfun_wishlists'
        end

        resources :quotes, only: [:create]
        resources :jobs, only: [:index, :show]

        get 'ping' => 'pages#ping'  # for availability monitoring
        get 'obscure/path/to/cron' => 'cron#run'

        # get 'search' => 'search#search'
        get 'tools', to: redirect('platforms')
        get 'platforms' => 'platforms#index'

        # embend a hackster badge with your project name / number
        get 'embed_widgets' => 'embed_widgets#index'
        get 'users/:id/embed' => 'users#embed'


        # get 'talk' => 'channels#show'
        # get 'talk/*all' => 'channels#show'

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
        get 'dc', to: redirect('/hackathons/hardware-weekend/washington')
        get 'nyc', to: redirect('/hackathons/hardware-weekend/new-york-city')
        get '/h/pebblerocksboulder', to: redirect('/hackathons/pebble-rocks-boulder/a-pebble-hackathon')
        get 'windows10kit', to: redirect('/s/windows10kit')

        # platform renamings
        get 'esp8266', to: redirect('/esp')
        get 'esp8266/products/esp8266-esp-01', to: redirect('/esp/products/esp8266-esp-01')
        get 'intel-edison', to: redirect('/intel/products/intel-edison')
        get 'intel-edison/projects', to: redirect('/intel/products/intel-edison')
        get 'intel-edison/products', to: redirect('/intel/products/intel-edison')
        get 'intel-edison/products/intel-edison', to: redirect('/intel/products/intel-edison')
        get 'intel-galileo', to: redirect('/intel/products/intel-galileo-gen-2')
        get 'intel-galileo/projects', to: redirect('/intel/products/intel-galileo-gen-2')
        get 'intel-galileo/products', to: redirect('/intel/products/intel-galileo-gen-2')
        get 'intel-galileo/products/intel-galileo-gen-2', to: redirect('/intel/products/intel-galileo-gen-2')
        get 'spark', to: redirect('/particle')
        get 'spark/projects', to: redirect('/particle/projects')
        get 'spark/makes', to: redirect('/particle/components')
        get 'spark/makes/spark-core', to: redirect('/particle/components/spark-core')
        get 'tinyduino', to: redirect('/tinycircuits')


        get 'about' => 'pages#about'
        get 'achievements' => 'pages#achievements'
        get 'business' => 'pages#business'
        get 'conduct' => 'pages#conduct'
        get 'home', to: redirect('/')
        get 'infringement_policy' => 'pages#infringement_policy'
        get 'privacy' => 'pages#privacy'
        get 'survey' => 'pages#survey'
        get 'terms' => 'pages#terms'
        get 'resources' => 'pages#resources'

        # updates counter for cached pages
        get 'users/stats' => 'stats#index'
        post 'stats' => 'stats#create'
        post 'projects/:id/views' => 'stats#legacy'

        post 'chats/:group_id' => 'chat_messages#create', as: :chat_messages
        post 'chats/:group_id/slack' => 'chat_messages#incoming_slack'
        get 'users/slack_settings' => 'chat_messages#slack_settings', as: :user_slack_settings
        post 'users/slack_settings' => 'chat_messages#save_slack_settings'

        get 'business/payments/:safe_id' => redirect { |params, request|
          URI.parse(request.url).tap { |uri| uri.path.sub!(/business\//i, '') }.to_s
        }, via: :get

        get 'payments/:safe_id' => 'payments#show', as: :payment
        post 'payments' => 'payments#create', as: :payments

        constraints(PlatformPage) do
          get ':slug' => 'platforms#show', as: :platform_home, slug: /[A-Za-z0-9_\-]{2,}/
          get ':user_name' => redirect('%{slug}/projects'), as: :platform_short, user_name: /[A-Za-z0-9_\-]{2,}/, constraints: { format: /(html|json)/ }
          scope ':slug', slug: /[A-Za-z0-9_\-]{2,}/, as: :platform, constraints: { format: /(html|json|js|atom|rss)/ } do
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
            get 'projects' => 'platforms#projects', as: :projects
            get 'platforms' => 'platforms#sub_platforms', as: :sub_platforms
          end
        end

        # constraints(PartPage) do
        #   get ':slug' => 'platforms#show', slug: /[A-Za-z0-9_\-]{2,}/, constraints: { format: /(html|json|atom|rss)/ }
        # end

        # root to: 'pages#home'
      end
      # end MainSite

      # just for arduino
      constraints(ClientSite) do
        scope ':path_prefix', path_prefix: /projecthub/ do
          get 'unauthorized' => 'pages#arduino_unauthorized', as: :arduino_unauthorized
        end
      end

      scope '(:path_prefix)', path_prefix: /projecthub/ do
        scope '(:locale)', locale: /[a-z]{2}(-[a-zA-Z]{2})?/ do
          constraints(MainSite) do
            resources :projects, only: [:index]
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
              get 'api_token' => 'api_tokens#show'
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
          get 'users/registration/toolbox' => 'users#toolbox', as: :user_toolbox
          get 'users/registration/toolbox_save' => 'users#toolbox_save', as: :user_toolbox_save
          patch 'users/registration/complete_profile' => 'users#after_registration_save'

          get 'users/:id/avatar' => 'users#avatar', as: :user_avatar

          resources :announcements, only: [:destroy] do
            resources :comments, only: [:create]
          end

          resources :code_files, only: [:create] do
            get 'download', on: :member
          end
          resources :comments, only: [:edit, :update, :destroy]

          resources :files, only: [:create, :show, :destroy] do
            get 'remote_upload' => 'files#check_remote_upload', on: :collection
            post 'remote_upload', on: :collection
            get 'signed_url', on: :collection
          end

          resources :projects, only: [:new, :create] do
            patch '' => 'projects#update', on: :member
            get '' => 'projects#redirect_to_slug_route', constraints: lambda{|req| req.params[:project_id] =~ /[0-9]+/ }
            post 'claim' => 'projects#claim', on: :member
            get 'embed', as: :old_embed
            get 'embed' => 'projects#embed_collection', on: :collection
            patch 'guest_name' => 'members#update_guest_name'
            get 'last' => 'projects#redirect_to_last', on: :collection
            get 'next' => 'projects#next', on: :member
            get 'publish' => 'projects#publish', on: :member
            get 'review' => 'review_threads#show', on: :member
            get 'settings' => 'external_projects#edit', on: :member
            patch 'settings' => 'external_projects#update', on: :member
            patch 'submit' => 'projects#submit', on: :member
            get 'team/edit' => 'members#edit', as: :edit_team
            patch 'team' => 'members#update'
            patch 'update_workflow' => 'projects#update_workflow', on: :member
            collection do
              resources :imports, only: [:new, :create], controller: :project_imports, as: :project_imports
            end
          end

          resources :base_articles, only: [], path: 'articles' do
            resources :comments, only: [:create]
            resources :respects, only: [:create] do
              get 'create' => 'respects#create', on: :collection, as: :create
              delete '' => 'respects#destroy', on: :collection
            end
          end

          get 'projects/review' => 'review_threads#index', as: :reviews

          constraints(ProjectPage) do
            get 'projects/:id/edit' => 'projects#edit', as: :edit_project
          end

          get 'projects/e/:user_name/:id' => 'external_projects#redirect_to_show', as: :external_project, id: /[0-9]+\-[A-Za-z0-9\-]+/  # legacy route (google has indexed them)

          resources :issues, only: [] do
            resources :comments, only: [:create]
          end

          resources :build_logs, only: [:destroy] do
            get '' => 'build_logs#show_redirect', on: :member
            resources :comments, only: [:create]
          end

          resources :messages, as: :conversations, controller: :conversations

          resources :notifications, only: [:index] do
            get 'edit' => 'notifications#edit', on: :collection
            patch '' => 'notifications#update', on: :collection
            get 'update' => 'notifications#update_from_link', on: :collection, as: :update
          end

          get 'site/login' => 'site_logins#new', as: :site_login
          post 'site/login' => 'site_logins#create'

          resources :followers, only: [] do
            collection do
              get 'create' => 'followers#create', as: :create
              # delete '' => 'followers#destroy'
            end
          end

          get 'profile/edit' => 'users#edit'
          patch 'profile' => 'users#update'

          constraints(MainSite) do
            get 'search' => 'search#search'
          end
          get 'tags/:tag' => redirect('/projects/tags/%{tag}'), via: :get, as: :deprecated_tags
          get 'tags' => 'search#tags', as: :deprecated_tags2
          get 'projects/tags/:tag' => 'search#tags', as: :tag
          get 'projects/tags' => 'search#tags'
          get 'robots' => 'pages#robots'
          get 'csrf' => 'pages#csrf'
          get 'guidelines' => 'pages#guidelines'

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
            scope ':slug', slug: /[A-Za-z0-9_\-]{2,}/, constraints: { format: /(html|json)/ } do
              get '' => 'users#show'
              scope 'projects', as: :user_projects do
                get '' => 'users#projects_public'
                get 'embed' => 'users#projects_embed'
                get 'drafts' => 'users#projects_drafts', as: :drafts
                get 'guest' => 'users#projects_guest', as: :guest
                get 'respected' => 'users#projects_respected', as: :respected
                get 'replicated' => 'users#projects_replicated', as: :replicated
              end
              get 'toolbox' => 'users#toolbox_show', as: :user_toolbox_show
              get 'comments' => 'users#comments', as: :user_comments
            end
            get ':user_name' => 'users#show', as: :user, user_name: /[A-Za-z0-9_\-]{2,}/, constraints: { format: /(html|json)/ }
          end

          constraints(MainSite) do
            get 'hackers', to: redirect('/community')
            get 'community' => 'users#index', as: :users
            get 'users/:id' => 'users#redirect_to_show', as: :hacker, format: /(html|js)/
          end

          constraints(ProjectPage) do
            scope ':user_name/:project_slug', as: :project, user_name: /[A-Za-z0-9_\-]*/, project_slug: /[A-Za-z0-9_\-]*-?[a-f0-9]{6}/, constraints: { format: /(html|json|js)/ } do
              get '' => 'projects#show', as: ''
              get 'embed' => 'projects#embed', as: :embed
              get 'print' => 'projects#print', as: :print
              resources :issues do
                patch 'update_workflow', on: :member
              end
              resources :logs, controller: :build_logs
            end
          end
          constraints(ExternalProjectPage) do
            get ':user_name/:project_slug' => 'external_projects#show', user_name: /[A-Za-z0-9_\-]*/, project_slug: /[A-Za-z0-9_\-]*-?[a-f0-9]{6}/
          end
          scope ':user_name/:project_slug', user_name: /[A-Za-z0-9_\-]*/, project_slug: /[A-Za-z0-9_\-]*-?[a-f0-9]{6}/ do
            patch '' => 'projects#update'
            delete '' => 'projects#destroy'
          end

          # old routes, kept for not break existing links
          scope ':user_name/:project_slug', user_name: /[A-Za-z0-9_\-]{2,}/, project_slug: /[A-Za-z0-9_\-]{2,}/, constraints: { format: /(html|json|js)/ } do
            get '' => 'projects#show', as: ''
            get 'embed' => 'projects#embed', as: :embed
            get 'issues' => 'issues#index'
            get 'logs' => 'build_logs#index'
          end

          constraints(ClientSite) do
            scope module: :client, as: :client do
              get '' => 'projects#index'
              get 'embed' => 'projects#embed'
              root to: 'projects#index'
            end
          end
        end
      end

      constraints(ClientSite) do
        scope module: :client, as: :client do
          get '' => 'projects#index'
          get 'embed' => 'projects#embed'
        end
      end

      get '' => 'pages#home'

      scope '(:path_prefix)', path_prefix: /projecthub/ do
        scope '(:locale)', locale: /[a-z]{2}(-[a-zA-Z]{2})?/ do
          root to: 'pages#home'
        end
      end
      get '*not_found' => 'application#not_found'  # find a way to not need this
    end
  end
end