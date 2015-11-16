class Admin::FieldsController < Admin::AdminController
  before_action :control_user
  before_action :control_editor, only: [:remove_attachment]

  def index
    redirect_to admin_path
  end

  def show
    redirect_to admin_path
  end

  def edit
    redirect_to admin_path
  end

  def update
    redirect_to admin_path
  end

  def new
    redirect_to admin_path
  end

  def create
    redirect_to admin_path
  end

  def destroy
    redirect_to admin_path
  end

  def remove_attachment
    @field = Field.find(params[:id])
    if (@field.type_field === "image")
      if (@field.image)
        @field.image = nil
        @field.save
        flash[:success] = $language['attachment_deleted']
        redirect_to admin_page_path(@field.page_id)
      else
        flash[:danger] = $language['attachment_not_found']
        redirect_to admin_page_path(@field.page_id)
      end
    elsif (@field.type_field === "file")
      if (@field.file)
        @field.file = nil
        @field.save
        flash[:success] = $language['attachment_deleted']
      else
        flash[:danger] = $language['attachment_not_found']
      end
      redirect_to admin_page_path(@field.page_id)
    else
      flash[:danger] = $language['attachment_not_found']
      redirect_to admin_pages_path
    end
  end

end
