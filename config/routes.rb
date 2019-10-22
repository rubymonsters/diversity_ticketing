Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    resources :passwords, controller: 'clearance/passwords', only: [:create, :new]
    resource :session, controller: 'sessions', only: [:create]

    resources :users, controller: 'users', only: [:create, :show, :edit, :update, :destroy]
    resources :users, controller: 'clearance/users', only: [:create] do
      resource :password,
        controller: 'clearance/passwords',
        only: [:create, :edit, :update, :destroy]
    end

    resources :events, except: [:destroy] do
      resources :applications, except: [:index, :submit, :admin_destroy]
      resources :drafts, only: [:create, :update, :edit, :show]
    end

    get '/sign_in', to: 'clearance/sessions#new', as: :sign_in
    get '/sign_up', to: 'clearance/users#new', as: :sign_up
    get '/:event_id/sign_up', to: 'clearance/users#new', as: :sign_up_event
    delete '/sign_out', to: 'clearance/sessions#destroy', as: :sign_out

    get '/users/:id/applications', to: 'users#applications', as: :user_applications
    get 'users/:id/delete', to: 'users#confirm_delete', as: :confirm_delete
    post 'users/:id/delete', to: 'users#delete_account', as: :delete_account
    delete 'users/:id', to: 'users#destroy', as: :destroy_user

    get '/past_events', to: 'events#index_past', as: :past_events
    get '/events/:event_id/continue_as_guest', to: 'applications#continue_as_guest', as: :continue_as_guest, constraints: { event_id: /\d.+/ }
    post '/events/preview', to: 'events#preview', as: :event_preview
    patch '/events/:event_id/application/:id/submit', to: 'applications#submit', as: :submit_event_application
    patch '/events/:event_id/drafts/:id/submit', to: 'drafts#submit', as: :submit_draft
    delete 'events/:id', to: 'events#destroy', as: :delete_event

    root 'home#home'
    get '/about', to: 'home#about', as: :about
    get '/faq', to: 'home#faq', as: :faq
    get '/privacy', to: 'home#privacy', as: :privacy
    get '/impressum', to: 'home#impressum', as: :impressum

    # Admin
    namespace :admin do
      resources :events, only: [:index, :show, :edit, :update, :destroy] do
        member do
          post :approve
        end
        collection do
          get :past
          get :reports
          get :annual
        end
        resources :applications, only: [:show, :destroy] do
          member do
            post :approve
            post :revert
            post :reject
          end
        end
      end
      resources :tags, only: [:index, :destroy, :create]
    end

    get '/admin', to: redirect('/en/admin/events')
    patch '/admin', to: 'application_process_options_handlers#update', as: :update_process
  end
end
