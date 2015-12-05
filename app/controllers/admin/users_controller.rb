class Admin::UsersController < Admin::AdminController
  before_action :control_user
  before_action :control_editor, only: [:new, :create]

  def index
    @users = User.paginate(:page => params[:page], :per_page => 12).order('name ASC')
    if(@question = User.ransack(params[:q]))
      @users = @question.result.paginate(:page => params[:page], :per_page => 12).order('name ASC')
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user].permit(:name, :email, :password, :password_confirmation, :permissions))
    if (@user.save)
      flash[:success] = $language['user_saved']
      redirect_to admin_user_path(@user)
    else
      flash[:danger] = $language['user_not_saved']
      error_list = ""
      @user.errors.full_messages.each do |error|
        error_list += " #{error}, "
      end
      flash[:warning] = error_list[0...-2]
      redirect_to new_admin_user_path
    end
  end

  def edit
    @user = User.find(params[:id])
    user_has_permissions?
  end

  def update
    @user = User.find(params[:id]) or redirect_to admin_path
    if(user_has_permissions?)
      control_password_to_update # Rimuovo parametro password per aggiornare senza modificare password
      if @user.update(params[:user].permit(:name, :email, :password, :password_confirmation))
        flash[:success] = $language['user_updated']
      else
        flash[:danger] = $language['user_not_updated']
        error_list = ""
        @user.errors.full_messages.each do |error|
          error_list += " #{error}, "
        end
        flash[:warning] = error_list[0...-2]
      end
      redirect_to admin_user_path(@user)
    end
  end

  def destroy
    @user = User.find(params[:id])
    if(user_has_permissions?)
      @user.destroy
      flash[:success] = $language['user_deleted']
      redirect_to admin_users_path
    end
  end

  private def control_password_to_update
    if(params[:user][:password].blank?)
      params[:user][:password]
      params[:user][:password_confirmation]
    end
  end

  private def user_has_permissions?
    if(session[:user_permissions] > @user.permissions || (session[:user_permissions] == @user.permissions && session[:user] != @user.id))
      flash[:info] = $language['permissions_error']
      redirect_to admin_user_path(@user) and return false
    end
    return true
  end

end
