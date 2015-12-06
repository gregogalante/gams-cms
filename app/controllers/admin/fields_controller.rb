class Admin::FieldsController < Admin::AdminController
  before_action :control_user
  before_action :control_editor, only: [:remove_attachment]
  before_action :control_admin, only: [:new, :create, :new_repeater, :create_repeater]

  def index
    redirect_to admin_path
  end

  def show
    redirect_to admin_path
  end

  def new
    @pages = Page.all
  end

  def create
    @field = Field.new(type_field: params[:type], name: params[:name].downcase, title: params[:title], page_id: params[:page], position: params[:position])
    if (@field.save)
      # output
      flash[:success] = $language['field_saved']
    else
      # output
      flash[:danger] = $language['field_not_saved']
      error_list = ""
      @field.errors.full_messages.each do |error|
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

  def new_repeater
    @pages = Page.all
    @types = Type.all
  end

  def create_repeater
    @field = Field.new(type_field: params[:type], name: params[:name].downcase, title: params[:title], page_id: params[:page], repeating: params[:repeating], position: params[:position])
    if (@field.save)
      # output
      flash[:success] = $language['field_saved']
    else
      # output
      flash[:danger] = $language['field_not_saved']
      error_list = ""
      @field.errors.full_messages.each do |error|
        error_list += " #{error}, "
      end
      flash[:warning] = error_list[0...-2]
    end
    redirect_to admin_configuration_path
  end

end
