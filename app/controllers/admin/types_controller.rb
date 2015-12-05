class Admin::TypesController < Admin::AdminController
  before_action :control_user
  before_action :control_editor, exept: [:index_objects, :show_objects]
  before_action :control_admin, only: [:new, :create]

  def index
    redirect_to admin_path
  end

  def show
    redirect_to admin_path
  end

  def new

  end

  def create
    @type = Type.new(name: params[:title_s].downcase, title_s: params[:title_s].downcase, title_p: params[:title_p].downcase, url: params[:url].downcase, visible: params[:visible])
    if(@type.save)
      # dynamic creation of the type table
      ActiveRecord::Migration.create_table @type.name.downcase do |t|
        t.string "url"
        t.string "title_#{I18n.default_locale}"
        # check multilanguage
        if($gams_config['has_languages'] === 'true' )
          if ($gams_config['languages_list'])
            $gams_config['languages_list'].each do |code|
              t.string "title_#{code}"
            end
          end
        end
        t.timestamps null: false
      end
      # dynamic creation of the type model
      File.open("#{Rails.root}/app/models/#{@type.name.downcase}.rb", "w+") do |page|
        page.write("class #{@type.name.capitalize} < ActiveRecord::Base \n")
        page.write("self.table_name = '#{@type.name.downcase}' \n")
        page.write("before_save { \n")
        page.write("self.url = self.url.parameterize('-') \n")
        page.write("} \n")
        page.write("validates :url, uniqueness: true, presence: true, length: {maximum: 50} \n")
        page.write("validates :title, presence: true \n")
        page.write("translates :title \n")
        page.write("###### \n")
        page.write("end")
      end
      # dynamic creation of the template files
      directory_name = "#{Rails.root}/app/views/template/#{@type.name}"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      File.open("#{directory_name}/index.html.erb", "w+") do |f|
        f.write("This is the index file for the type #{@type.title_s}")
      end
      File.open("#{directory_name}/show.html.erb", "w+") do |f|
        f.write("This is the show file for the type #{@type.title_s}")
      end
      # output
      flash[:success] = "The new type #{@type.title_s} is saved"
    else
      # output
      flash[:danger] = "Sorry, the new type is not saved"
      error_list = ""
      @type.errors.full_messages.each do |error|
        error_list += " #{error}, "
      end
      flash[:warning] = error_list[0...-2]
    end
    redirect_to admin_configuration_path
  end

  def edit
    redirect_to admin_path
  end

  def update
    redirect_to admin_path
  end

  def destroy
    redirect_to admin_path
  end

  def index_objects
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

  def show_objects
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

  def new_objects
    if(@type = Type.find_by(name: params[:typename]))
      @type_model = @type.name.capitalize.constantize
      @type_object = @type_model.new
      @typefields = Typefield.where(type_id: @type.id).order('position ASC')

      if(params[:locale])
        @title_field_name = "title_#{params[:locale]}"
      else
        @title_field_name = "title_#{I18n.default_locale}"
      end

      # For image fields
      @images = Image.all.reverse

    else
      flash[:warning] = $language['error']
      redirect_to admin_path
    end
  end

  def create_objects
    if(params[:type] and @type = Type.find_by(name: params[:type]))
      # get type model and params name
      table = @type.name.capitalize.constantize
      params_name = @type.name
      # create new object
      @type_object = table.new(params[params_name].permit!)
      if(@type_object.save)
        flash[:success] = $language['type_saved']
        redirect_to admin_show_type_objects_path(@type.name, @type_object.id)
      else
        flash[:danger] = $language['type_not_saved']
        error_list = ""
        @type.errors.full_messages.each do |error|
          error_list += " #{error}, "
        end
        flash[:warning] = error_list[0...-2]
        redirect_to admin_index_type_objects_path(@type.name)
      end
    else
      flash[:warning] = $language['error']
      redirect_to admin_path
    end
  end

  def edit_objects
    if(@type = Type.find_by(name: params[:typename]))
      @type_model = @type.name.capitalize.constantize
      @type_object = @type_model.find(params[:objectid])
      @typefields = Typefield.where(type_id: @type.id).order('position ASC')

      if(params[:locale])
        @title_field_name = "title_#{params[:locale]}"
      else
        @title_field_name = "title_#{I18n.default_locale}"
      end

      # For image fields
      @images = Image.all.reverse

    else
      flash[:warning] = $language['error']
      redirect_to admin_path
    end
  end

  def update_objects
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
      redirect_to admin_show_type_objects_path(@type.name, params[:objectid])
    else
      flash[:warning] = $language['error']
      redirect_to admin_path
    end
  end

  def destroy_objects
    if(params[:typename] and params[:objectid] and @type = Type.find_by(name: params[:typename]))
      @type_model = @type.name.capitalize.constantize
      @type_object = @type_model.find(params[:objectid])
      @type_object.destroy
      flash[:success] = $language['type_deleted']
      redirect_to admin_index_type_objects_path(@type.name)
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
