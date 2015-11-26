class Admin::TypesController < Admin::AdminController
  before_action :control_user
  before_action :control_editor, exept: [:index, :show]

  def index
    if(@type = Type.find_by(name: params[:typename]))
      type_model = @type.name.capitalize.constantize
      @type_objects = type_model.paginate(:page => params[:page], :per_page => 12).order('created_at DESC')
      if(@question = type_model.ransack(params[:q]))
        @type_objects = @question.result.paginate(:page => params[:page], :per_page => 12).order('created_at DESC')
      end
    else
      flash[:warning] = $language['error']
      redirect_to admin_path
    end
  end

  def show
    if(params[:typename] and params[:objectid] and @type = Type.find_by(name: params[:typename]))
      @type_model = @type.name.capitalize.constantize
      @type_object = @type_model.find(params[:objectid])
      @typefields = Typefield.where(type_id: @type.id)

      if(params[:locale])
        @title_field_name = "title_#{params[:locale]}"
      else
        @title_field_name = "title_#{I18n.default_locale}"
      end
    else
      flash[:warning] = $language['error']
      redirect_to admin_path
    end
  end

  def edit
    if(@type = Type.find_by(name: params[:typename]))
      @type_model = @type.name.capitalize.constantize
      @type_object = @type_model.find(params[:objectid])
      @typefields = Typefield.where(type_id: @type.id).order('position ASC')

      if(params[:locale])
        @title_field_name = "title_#{params[:locale]}"
      else
        @title_field_name = "title_#{I18n.default_locale}"
      end
    else
      flash[:warning] = $language['error']
      redirect_to admin_path
    end
  end

  def update
    if(params[:type] and @type = Type.find_by(name: params[:type]))
      @type_model = @type.name.capitalize.constantize
      @type_object = @type_model.find(params[:objectid])
      if(@type_object.update(params[@type.name].permit!))
        flash[:success] = $language['type_updated']
      else
        flash[:danger] = $language['type_not_updated']
        error_list = ""
        @type_object.errors.full_messages.each do |error|
          error_list += " #{error}, "
        end
        flash[:warning] = error_list[0...-2]
      end
      redirect_to admin_show_type_path(@type.name, params[:objectid])
    else
      flash[:warning] = $language['error']
      redirect_to admin_path
    end
  end

  def new
    if(@type = Type.find_by(name: params[:typename]))
      @type_model = @type.name.capitalize.constantize
      @type_object = @type_model.new
      @typefields = Typefield.where(type_id: @type.id).order('position ASC')

      if(params[:locale])
        @title_field_name = "title_#{params[:locale]}"
      else
        @title_field_name = "title_#{I18n.default_locale}"
      end

    else
      flash[:warning] = $language['error']
      redirect_to admin_path
    end
  end

  def create
    if(params[:type] and @type = Type.find_by(name: params[:type]))
      # get type model and params name
      table = @type.name.capitalize.constantize
      params_name = @type.name
      # create new object
      @type_object = table.new(params[params_name].permit!)
      if(@type_object.save)
        flash[:success] = $language['type_saved']
        redirect_to admin_show_type_path(@type.name, @type_object.id)
      else
        flash[:danger] = $language['type_not_saved']
        error_list = ""
        @type.errors.full_messages.each do |error|
          error_list += " #{error}, "
        end
        flash[:warning] = error_list[0...-2]
        redirect_to admin_types_path(@type.name)
      end
    else
      flash[:warning] = $language['error']
      redirect_to admin_path
    end
  end

  def destroy
    if(params[:typename] and params[:objectid] and @type = Type.find_by(name: params[:typename]))
      @type_model = @type.name.capitalize.constantize
      @type_object = @type_model.find(params[:objectid])
      @type_object.destroy
      flash[:success] = $language['type_deleted']
      redirect_to admin_types_path(@type.name)
    else
      flash[:warning] = $language['error']
      redirect_to admin_path
    end
  end

  def remove_attachment
    table_name = params[:tablename]
    type_id = params[:typeid]
    field_name = params[:typefieldname]
    @type = table_name.capitalize.constantize.find(type_id)
    if(@type.send(field_name))
      @type.send(field_name).destroy
      @type.save
      flash[:success] = $language['attachment_deleted']
    else
      flash[:danger] = $language['attachment_not_found']
    end
    redirect_to admin_edit_type_path(table_name, type_id)
  end

end
