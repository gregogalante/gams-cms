class Admin::NotesController < Admin::AdminController
  before_action :control_user
  before_action :control_editor, exept: [:index, :show]

  def index
    @notes = Note.paginate(:page => params[:page], :per_page => 12).order('created_at DESC')
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(params[:note].permit(:title, :content, :style))
    if (@note.save)
      flash[:success] = $language['note_saved']
      redirect_to admin_note_path(@note)
    else
      flash[:danger] = $language['note_not_saved']
      error_list = ""
      @note.errors.full_messages.each do |error|
        error_list += " #{error}, "
      end
      flash[:warning] = error_list[0...-2]
      redirect_to new_admin_note_path
    end
  end

  def show
    @note = Note.find(params[:id])
  end

  def edit
    @note = Note.find(params[:id])
  end

  def update
    @note = Note.find(params[:id]) or redirect_to admin_path
    if @note.update(params[:note].permit(:title, :content, :style))
      flash[:success] = $language['note_updated']
    else
      flash[:danger] = $language['note_not_updated']
      error_list = ""
      @note.errors.full_messages.each do |error|
        error_list += " #{error}, "
      end
      flash[:warning] = error_list[0...-2]
    end
    redirect_to admin_note_path(@note)
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy
    flash[:success] = $language['note_deleted']
    redirect_to admin_notes_path
  end

end
