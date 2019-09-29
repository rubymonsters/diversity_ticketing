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
    end

    resources :events, except: [:destroy] do
      resources :drafts, only: [:create, :update, :edit, :show]
    end

    resources :admin_events, except: [:edit, :update] do
      member do
        post :approve
      end
    end

    resources :tags, only: [:index, :destroy, :create]

    get '/sign_in', to: 'clearance/sessions#new', as: :sign_in
    delete '/sign_out', to: 'clearance/sessions#destroy', as: :sign_out
    get '/sign_up', to: 'clearance/users#new', as: :sign_up
    get '/:event_id/sign_up', to: 'clearance/users#new', as: :sign_up_event
    get '/past_events', to: 'events#index_past', as: :past_events
    get '/admin', to: 'admin_events#index'
    get '/admin_annual', to: 'admin_events#annual_events_report'
    delete 'events/:id', to: 'events#destroy', as: :delete_event
    patch '/events/:event_id/application/:id/submit', to: 'applications#submit', as: :submit_event_application
    get '/events/:id/admin', to: 'admin_events#show', as: :event_admin
    post '/events/preview', to: 'events#preview', as: :event_preview
    get '/about', to: 'home#about', as: :about
    get '/faq', to: 'home#faq', as: :faq
    get '/privacy', to: 'home#privacy', as: :privacy
    get '/impressum', to: 'home#impressum', as: :impressum
    get '/users/:id/applications', to: 'users#applications', as: :user_applications
    delete '/events/:event_id/application/:id', to: 'admin_applications#destroy', as: :admin_event_application
    post '/events/:event_id/applications/:id/approve', to: 'admin_applications#approve', as: :approve_event_application
    post '/events/:event_id/applications/:id/reject', to: 'admin_applications#reject', as: :reject_event_application
    post '/events/:event_id/applications/:id/revert', to: 'admin_applications#revert', as: :revert_event_application
    get '/events/:event_id/applications/:id/show_admin', to: 'admin_applications#show', as: :show_admin_event_application
    get '/events/:event_id/continue_as_guest', to: 'applications#continue_as_guest', as: :continue_as_guest, constraints: { event_id: /\d.+/ }
    delete 'users/:id', to: 'users#destroy', as: :destroy_user
    get 'users/:id/delete', to: 'users#confirm_delete', as: :confirm_delete
    post 'users/:id/delete', to: 'users#delete_account', as: :delete_account
    patch '/events/:event_id/drafts/:id/submit', to: 'drafts#submit', as: :submit_draft

    patch '/admin', to: 'application_process_options_handlers#update', as: :update_process

    root 'home#home'
  end
end
