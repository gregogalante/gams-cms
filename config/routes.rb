Rails.application.routes.draw do

  # ADMIN SECTION ###########################
  get 'admin', :to => 'admin/admin#login'
  namespace :admin do

    get 'home', :to => 'admin#home', as: 'home'
    # authentication routes
    post 'access', :to => 'admin#access'
    get 'logout', :to => 'admin#logout'
    # configurations routes
    get 'configuration', :to => 'config#home', as: 'configuration'
    post'configuration/update_settings', :to => 'config#update_settings', as: 'config_settings'
    get 'configuration/generate_migration', :to => 'config#generate_migration', as: 'config_migrations'
    get 'configuration/guide', :to => 'config#guide', as: 'config_guide'
    get 'configuration/development', :to => 'config#development', as: 'config_development'
    get 'configuration/languages', :to => 'config#languages', as: 'config_languages'
    post 'configuration/languages/initialize', :to => 'config#languages_initialize', as: 'config_languages_initialize'
    # users
    resources :users
    # notes
    resources :notes
    # pages
    resources :pages
    #images
    resources :images
    # fields
    get 'fields/new_repeater', :to => 'fields#new_repeater', as: 'new_field_repeater'
    post 'fields/create_repeater', :to => 'fields#create_repeater', as: 'create_field_repeater'
    delete 'fields/remove-att/:id', :to => 'fields#remove_attachment', as: 'delete_field_attachment'
    resources :fields
    # types
    get '/type/:typename', :to => 'types#index_objects', as: 'index_type_objects'
    get '/type/:typename/show/:objectid', :to => 'types#show_objects', as: 'show_type_objects'
    get '/type/:typename/new', :to => 'types#new_objects', as: 'new_type_objects'
    post '/type/:typename/create', :to => 'types#create_objects', as: 'create_type_objects'
    get '/type/:typename/edit/:objectid', :to => 'types#edit_objects', as: 'edit_type_objects'
    patch '/type/:typename/update/:objectid', :to => 'types#update_objects', as: 'update_type_objects'
    delete '/type/:typename/delete/:objectid', :to => 'types#destroy_objects', as: 'delete_type_objects'
    delete '/type/remove-att/:tablename/:typeid/:typefieldname' => 'types#remove_attachment', as: 'delete_typefield_attachment'
    resources :types
    #typefields
    resources :typefields
  end
  ###########################################

  # TEMPLATE SECTION ########################

  if($gams_config['has_languages'] === 'true')
    scope "/:locale" do
      root 'template/template#homepage'
      match '/:url', :to => 'template/template#routes', via: :get
      match '/:url/:id', :to => 'template/template#routes', via: :get
    end
  else
      root 'template/template#homepage'
      match '/:url', :to => 'template/template#routes', via: :get
      match '/:url/:id', :to => 'template/template#routes', via: :get
  end

  ###########################################

end
