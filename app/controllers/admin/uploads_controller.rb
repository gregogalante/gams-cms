class Admin::UploadsController < Admin::AdminController
  before_action :control_user

  def index
    @uploads = Upload.all.reverse
    @upload = Upload.new
  end

  def create
    @upload = Upload.new(params[:upload].permit!)
    # Ajax update for uploads list
    if(@upload.save)
      @uploads = Upload.all.reverse
      # QUA BISOGNA UTILIZZARE LA FUNZIONE ajaxLoad() PER AGGIORNARE LA LISTA
      # DI UPLOADS IN REALTIME.
    end
  end

end
