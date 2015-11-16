class Admin::AdminController < ActionController::Base
  layout 'admin/admin'

  before_action :control_user, :except => [:login, :access]
  before_action :control_admin, :only => [:settings, :update_settings]
  before_action :set_locale

  # Static actions
  def home
    @notes = Note.last(4)
    @user = User.find(session[:user])
  end

  # Languages support
  def default_url_options(options = {})
    if($gams_config['has_languages'] === 'true')
      { locale: I18n.locale }.merge options
    else
      { :only_path => false }
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # User actions
  def login
    if (session[:user])
      redirect_to admin_home_path
    end
  end

  def access
    if (!params[:user])
      redirect_to admin_path
    end
    @user = User.find_by_email(params[:user][:email])
    # Authenticate user
    if @user && @user.authenticate(params[:user][:password])
      # Create sessions
      session[:user] = @user.id
      session[:user_permissions] = @user.permissions
      # output
      flash[:info] = "#{$language['welcome'].capitalize} #{@user.name}"
    else
      flash[:danger] = $language['login_bad']
    end
    # Redirect to admin panel
    redirect_to admin_path
  end

  def logout
    if(session[:user])
      session.delete(:user)
      session.delete(:user_permissions)
    end
    flash[:success] = $language['logout_good']
    redirect_to admin_path
  end

  # Settings sections actions
  def settings
    # get updated data of config.yml
    load_config_yaml()
  end

  def update_settings
    require 'yaml' # Built in, no gem required
    config = YAML::load_file("#{Rails.root}/config/config.yml") #Load
    # Site name
    if(params[:header_text])
      config['header_text'] = params[:header_text]
    end
    if(params[:footer_text])
      config['footer_text'] = params[:footer_text]
    end
    if(params[:footer_url])
      config['footer_url'] = params[:footer_url]
    end
    File.open("#{Rails.root}/config/config.yml", 'w') {|f| f.write config.to_yaml }
    # get updated data of config.yml
    load_config_yaml()
    # output
    flash[:success] = $language['setting_updated']
    redirect_to admin_settings_path
  end

  def generate_migration
    # delete old gams_seeds files
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/db/seeds/*"))
    # generate new gams_seeds file
    File.open("#{Rails.root}/db/gams-seeds/gams_seeds.rb", "a") do |page|
      # generate pages seeds
      page.write("# DEFAULT PAGES \n")
      @pages = Page.all
      @pages.each do |object_page|
        page.write("Page.create(title: '#{object_page.title}', url: '#{object_page.url}') \n")
      end
      # generate fields seeds
      page.write("# DEFAULT FIELDS \n")
      @fields = Field.all
      @fields.each do |object_field|
        page.write("Field.create(type_field: '#{object_field.type_field}', name: '#{object_field.name}', title: '#{object_field.title}', repeating: '#{object_field.repeating}', page_id: '#{object_field.page_id}') \n")
      end
      # generate types seeds
      page.write("# DEFAULT TYPES \n")
      @types = Type.all
      @types.each do |object_type|
        page.write("Type.create(title: '#{object_type.title}', title_p: '#{object_type.title_p}', url: '#{object_type.url}') \n")
      end
      # generate typefields seeds
      page.write("# DEFAULT TYPEFIELDS \n")
      @typefields = Typefield.all
      @typefields.each do |object_typefield|
        page.write("Typefield.create(type_field: '#{object_typefield.type_field}', name: '#{object_typefield.name}', title: '#{object_typefield.title}', type_id: '#{object_typefield.type_id}') \n")
      end
    end
    # delete old migrations files
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/db/gams-migrate/*"))
    # generate new migration file
    Type.all.each do |type|
        File.open("#{Rails.root}/db/gams-migrate/#{Time.now.to_s(:number)}_create_#{type.title.downcase}.rb", "w+") do |page|
          page.write("class Create#{type.title.capitalize} < ActiveRecord::Migration \n   def change \n ")
          page.write("  create_table :#{type.title.downcase} do |t| \n    t.timestamps null: false \n")
            #Get tables
            table = type.title.capitalize.constantize
            table_list = table.new.attribute_names.to_a
            table_list.each do |table|
              if(table != 'id' && table != 'created_at' && table != 'updated_at')
                page.write("    t.text '#{table}' \n")
              end
            end
          page.write("   end \n end\nend")
        end
    end
    flash[:success] = "Yeah DEV. Go in production ;)"
    redirect_to admin_settings_path
  end

  # Action to config.yml access
  protected def load_config_yaml
    $gams_config = YAML.load_file("#{Rails.root}/config/config.yml")
  end

  # Security actions
  protected def control_user
    if (!session[:user])
      flash[:info] = $language['no_login']
      redirect_to admin_path and return false
    end
  end

  protected def control_admin
    if(session[:user_permissions] > 0)
      flash[:info] = $language['permissions_error']
      redirect_to admin_path and return false
    end
  end

  protected def control_editor
    if(session[:user_permissions] > 1)
      flash[:info] = $language['permissions_error']
      redirect_to admin_path and return false
    end
  end

  protected def control_collaborator
    if(session[:user_permissions] > 2)
      flash[:info] = $language['permissions_error']
      redirect_to admin_path and return false
    end
  end

end
