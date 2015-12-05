class Admin::PagesController < Admin::AdminController
  before_action :control_user
  before_action :control_editor, only: [:edit, :update, :show]
  before_action :control_admin, only: [:new, :create]

  def index
    @pages = Page.paginate(:page => params[:page], :per_page => 12).order('title ASC')
  end

  def show
    redirect_to edit_admin_page_path(params[:id])
  end

  def new

  end

  def create
    @page = Page.new(title: params[:title], url: params[:url].downcase)
    if (@page.save)
      # create template file
      File.open("#{Rails.root}/app/views/template/pages/#{@page.url}.html.erb", "w+") do |page|
        page.write("This is the '#{@page.title}' template file!")
      end
      # output
      flash[:success] = "The new page #{@page.title} is saved"
    else
      # output
      flash[:danger] = "Sorry, the new page is not saved"
      error_list = ""
      @page.errors.full_messages.each do |error|
        error_list += " #{error}, "
      end
      flash[:warning] = error_list[0...-2]
    end
    redirect_to admin_configuration_path
  end

  def edit
    @page = Page.find(params[:id])
    @fields = Field.where(page_id: @page.id).order("position ASC")
    # Image list for image fields
    @images = Image.all.reverse
  end

  def update
    error_list = ""
    params[:field].each do |field_id,field_value|
      @field = Field.find(field_id)
      if (!@field.update(value: field_value))
        @field.errors.full_messages.each do |error|
          error_list += " #{error}, "
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

  def destroy
    redirect_to admin_pages_path
  end

end
