class Admin::PagesController < Admin::AdminController
  before_action :control_user
  before_action :control_editor, only: [:edit, :update, :show]

  def index
    @pages = Page.paginate(:page => params[:page], :per_page => 12).order('title ASC')
  end

  def show
    redirect_to edit_admin_page_path(params[:id])
  end

  def edit
    @page = Page.find(params[:id])
    @fields = Field.where(page_id: @page.id).order("position ASC")
  end

  def update
    error_list = ""
    params[:field].each do |field_id,field_value|
      @field = Field.find(field_id)
      case @field.type_field
      when "image"
        if(!@field.update(image: field_value))
          @field.errors.full_messages.each do |error|
            error_list += " #{error}, "
          end
        end
      when "file"
        if(!@field.update(file: field_value))
          @field.errors.full_messages.each do |error|
            error_list += " #{error}, "
          end
        end
      else
        if (!@field.update(value: field_value))
          @field.errors.full_messages.each do |error|
            error_list += " #{error}, "
          end
        end
      end
    end
    if (!error_list.blank?)
      flash[:danger] = $language['page_not_updated']
      flash[:warning] = error_list[0...-2]
    else
      flash[:success] = $language['page_updated']
    end
    redirect_to admin_page_path(params[:id])
  end

  def new
    redirect_to admin_pages_path
  end

  def create
    redirect_to admin_pages_path
  end

  def destroy
    redirect_to admin_pages_path
  end

end
