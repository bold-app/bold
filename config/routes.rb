Rails.application.routes.draw do

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  root 'frontend/contents#show'

  # To separate the backend from public sites, we wrap it with a constraint
  # that only allows access via a pre-configured 'backend_host'. See
  # config/bold.yml.sample for how to set that.
  #
  # Besides making the backend accessible exclusively via a dedicated hostname
  # (i.e. cms.yoursite.com) this has the nice side effect of freeing up the URL
  # name space for your sites so you dont have to worry about collisions with
  # Bold's backend.
  #
  # If you don't care about this kind of separation, set backend_host to your
  # sites public hostname. Your site will then redirect requests to backend
  # paths to Bold's login page instead of rendering the 404 page.
  #
  constraints Bold::Routes::BackendConstraint.new do

    devise_for :users

    # initial setup
    # the constraint hides these routes once at least one site is present.
    constraints Bold::Routes::SetupConstraint.new do
      namespace :setup do
        root 'users#new', as: 'root'
        resource :user, only: %i(new create)
        resource :site, only: %i(new create)
      end
    end

    # backend
    namespace :bold do

      root to: 'sites#index', as: :root

      resource :profile, only: %i(edit update edit_password update_password edit_email update_email) do
        collection do
          get :edit_email, :edit_password
          put :update_email, :update_password
        end
      end


      resources :sites, only: %i(show index)  do

        namespace :activity do
          resources :stats, only: :index do
            collection do
              get :visits_per_day
            end
          end
          resources :comments, shallow: true, only: %i(index destroy) do
            member do
              patch :restore, :mark_spam, :mark_ham, :approve, :unapprove
            end
            collection do
              delete :destroy_spam
            end
          end
        end

        resources :asset_links, only: :new

        resources :assets, shallow: true do
          collection do
            post :create_from_url
            get :gallery
            delete :bulk_destroy
          end
          member do
            post :pick
          end
        end
        resources :pages, shallow: true do
          member do
            get :diff, :change_template
            patch :update_template
            delete :delete_draft
          end
        end
        resources :posts, shallow: true do
          member do
            get :diff, :change_template
            patch :update_template
            delete :delete_draft
          end
        end

        # Site Settings
        namespace :settings do
          root 'settings#edit', as: 'root'

          resources :backups, only: %i(index create)
          resources :categories, shallow: true
          resources :tags, shallow: true, only: %i(index edit update destroy)

          resources :navigations, shallow: true, only: %i(index create update destroy) do
            collection{ put :sort }
          end

          resources :plugins, only: %i(index edit update enable destroy) do
            member{ put :enable }
          end

          resource :settings, only: %i(edit update favicon set_favicon) do
            member do
              get :favicon
              get :logo
            end
          end

          resource :html_snippet, only: %i(edit update)

          resources :site_users do
            member do
              put :resend_invitation
              delete :revoke_invitation
            end
          end

          resources :themes, only: %i(index edit update enable) do
            member{ put :enable }
          end
        end

        post 'undo/:id' => 'undo#create', as: :undo
      end

    end


    # global admin
    namespace :admin do

      resources :sites

      resources :users do
        collection do
          get :invited
          get :locked
        end
        member do
          put :lock
          put :unlock
          put :reset_password
        end
        resources :site_users, only: %i(new create edit update destroy)
      end

      resources :invitations, only: %i( index new create update destroy )

    end

  end # of BackendConstraint


  # Set up theme and plugin routes
  # While themes and plugins could just define their own routes via their own
  # config/routes.rb, these would end up after the catch all below and thus
  # never be reached. Instead, declare your routes when registering the
  # extension.
  Bold::Plugin.install_routes! self
  Bold::Theme.install_routes! self

  mount Ahoy::Engine => "/ahoy"

  # Frontend routes

  # retina support
  get 'displayconfig' => 'frontend/assets#display_config', as: :display_config

  # Sitemap
  get 'sitemap.xml' => 'frontend/sitemaps#show', as: :sitemap, defaults: { format: :xml }

  # site specific css / js
  get 'site' => 'frontend/site_contents#show', as: :site_content

  # Favicon
  get 'favicon.ico' => 'frontend/assets#favicon', as: :favicon

  # Assets
  get 'files/inline/:id(/:version)'    => 'frontend/assets#show',     as: :file
  get 'files/:id(/:version)/:filename' => 'frontend/assets#download', as: :download


  # Posts by Author
  get 'authors/:author' => 'frontend/contents#author', as: :author_posts, author: /.+/

  # redirect requests with single-digit months to 0x month format
  # to avoid duplicate content penalties
  get ':year/:month/*slug',
    constraints: { year: /\d{4}/, month: /\d/ },
    to: redirect('/%{year}/0%{month}/%{slug}')

  # Archive
  constraints year: /\d{4}/, month: /\d\d/ do
    get ':year(/:month)'      => 'frontend/contents#archive', as: :archive
  end

  # Contact message creation
  post 'contact/*path' => 'frontend/contact_messages#create', as: :contact_messages, format: false

  # Pages, Posts, Tags, Categories
  get  '*path' => 'frontend/contents#show',   as: :content, format: false
  # Comment creation
  post '*path' => 'frontend/comments#create', as: :comments, format: false

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
