Rails.application.routes.draw do
  resources :passwords, controller: 'clearance/passwords', only: [:create, :new]
  resource :session, controller: 'sessions', only: [:create]

  resources :users, controller: 'users', only: [:create, :show, :edit, :update, :destroy]
  resources :users, controller: 'clearance/users', only: [:create] do
    resource :password,
      controller: 'clearance/passwords',
      only: [:create, :edit, :update, :destroy]
  end

  resources :events do
    resources :applications, except: [:index, :submit, :admin_destroy]
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
  get '/past_events', to: 'events#index_past', as: :past_events
  get '/admin', to: 'admin_events#index'
  get '/admin_anual', to: 'admin_events#anual_events_report'
  delete '/events/:event_id/application/:id', to: 'applications#admin_destroy', as: :admin_event_application
  patch '/events/:event_id/application/:id/submit', to: 'applications#submit', as: :submit_event_application
  get '/events/:id/admin', to: 'admin_events#show', as: :event_admin
  post '/events/preview', to: 'events#preview', as: :event_preview
  get '/about', to: 'home#about', as: :about
  get '/faq', to: 'home#faq', as: :faq
  get '/privacy', to: 'home#privacy', as: :privacy
  get '/users/:id/applications', to: 'users#applications', as: :user_applications
  post '/events/:event_id/applications:id/approve', to: 'applications#approve', as: :approve_event_application
  post '/events/:event_id/applications:id/reject', to: 'applications#reject', as: :reject_event_application
  post '/events/:event_id/applications:id/revert', to: 'applications#revert', as: :revert_event_application
  delete 'users/:id', to: 'users#destroy', as: :destroy_user
  get 'users/:id/delete', to: 'users#delete_account', as: :delete_account
  root 'home#home'
end
