class Admin::ImagesController < Admin::AdminController
  before_action :control_user

  def index
    @images = Image.paginate(:page => params[:page], :per_page => 12).order('created_at DESC')
    if(@question = Image.ransack(params[:q]))
      @images = @question.result.paginate(:page => params[:page], :per_page => 12).order('created_at DESC')
    end
  end

  def show
    @image = Image.find(params[:id])
    if(params[:locale])
      @title_field_name = "title_#{params[:locale]}"
      @description_field_name = "description_#{params[:locale]}"
    else
      @title_field_name = "title_#{I18n.default_locale}"
      @description_field_name = "description_#{I18n.default_locale}"
    end
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(params[:image].permit!)
    # Ajax update for images list
    if(@image.save)
      @images = Image.all.reverse
      respond_to do |format|
        format.js # Response not working
	    end
    end
  end

  def edit
    @image = Image.find(params[:id])
    if(params[:locale])
      @title_field_name = "title_#{params[:locale]}"
      @description_field_name = "description_#{params[:locale]}"
    else
      @title_field_name = "title_#{I18n.default_locale}"
      @description_field_name = "description_#{I18n.default_locale}"
    end
  end

  def update
    @image = Image.find(params[:id]) or redirect_to admin_path
    if @image.update(params[:image].permit(:title, :description))
      flash[:success] = $language['image_updated']
    else
      flash[:danger] = $language['image_not_updated']
      error_list = ""
      @image.errors.full_messages.each do |error|
        error_list += " #{error}, "
      end
      flash[:warning] = error_list[0...-2]
    end
    redirect_to admin_image_path(@image)
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    flash[:success] = $language['image_deleted']
    redirect_to admin_images_path
  end

end
