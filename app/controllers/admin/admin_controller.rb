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
