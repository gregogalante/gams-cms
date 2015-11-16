Rails.application.routes.draw do

  # ADMIN SECTION ###########################
  get 'admin', :to => 'admin/admin#login'
  namespace :admin do
    get 'home', :to => 'admin#home', as: 'home'
    # authentication routes
    post 'access', :to => 'admin#access'
    get 'logout', :to => 'admin#logout'
    # settings routes
    get 'settings', :to => 'admin#settings', as: 'settings'
    post'update_settings', :to => 'admin#update_settings'
    get 'generate_migration', :to => 'admin#generate_migration'
    # configurations routes
    get 'settings/config/guide', :to => 'config#guide', as: 'config_guide'
    get 'settings/config/development', :to => 'config#development', as: 'config_development'
    # - languages
    get 'settings/config/language/configuration', :to => 'config#language_configuration', as: 'config_language_configuration'
    post 'settings/config/language/initialize', :to => 'config#language_initialize', as: 'config_language_initialize'
    # - pages
    get 'settings/config/page/new', :to => 'config#page_new', as: 'config_page_new'
    post 'settings/config/page/create', :to => 'config#page_create', as: 'config_page_create'
    # - fields
    get 'settings/config/field/new', :to => 'config#field_new', as: 'config_field_new'
    post 'settings/config/field/create', :to => 'config#field_create', as: 'config_field_create'
    # - repeaters
    get 'settings/config/repeater/new', :to => 'config#repeater_new', as: 'config_repeater_new'
    post 'settings/config/repeater/create', :to => 'config#repeater_create', as: 'config_repeater_create'
    # - types
    get 'settings/config/type/new', :to => 'config#type_new', as: 'config_type_new'
    post 'settings/config/type/create', :to => 'config#type_create', as: 'config_type_create'
    # - typesfields
    get 'settings/config/typefield/new', :to => 'config#typefield_new', as: 'config_typefield_new'
    post 'settings/config/typefield/create', :to => 'config#typefield_create', as: 'config_typefield_create'

    # users
    resources :users
    # notes
    resources :notes
    # pages
    resources :pages
    # fields
    resources :fields
    delete 'fields/remove-att/:id', :to => 'fields#remove_attachment', as: 'delete_field_attachment'

    # types
    get '/type/:typename', :to => 'types#index', as: 'types'
    get '/type/:typename/show/:objectid', :to => 'types#show', as: 'show_type'
    get '/type/:typename/new', :to => 'types#new', as: 'new_type'
    post '/type/:typename/create', :to => 'types#create', as: 'create_type'
    get '/type/:typename/edit/:objectid', :to => 'types#edit', as: 'edit_type'
    patch '/type/:typename/update/:objectid', :to => 'types#update', as: 'update_type'
    delete '/type/:typename/delete/:objectid', :to => 'types#destroy', as: 'delete_type'
    delete '/type/remove-att/:tablename/:typeid/:typefieldname' => 'types#remove_attachment', as: 'delete_typefield_attachment'
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
