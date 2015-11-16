class Template::TemplateController < ActionController::Base
  layout 'template/template'

  # Homepage action
  def homepage
    if(@page = Page.find_by(url: 'homepage'))
      render "template/pages/homepage.html.erb"
    else
      redirect_to admin_path
    end
  end

  # Actions for pages and types
  def routes
    # params url, no params id, url is a page
    if(params[:url] and !params[:id] and @page = Page.find_by(url: params[:url] ))
      @head_title = @page.title.capitalize
      render "template/pages/#{params[:url] }.html.erb"
    # params url, no params id, url is a type
  elsif(params[:url] and !params[:id] and @type = Type.find_by(url: params[:url]) and @type.visible)
      table = @type.name.capitalize.constantize
      @type_objects = table.all
      @head_title = @type.title_p.capitalize
      render "template/#{@type.title}/index.html"
    # params url, params id, url is a type
    elsif(params[:url] and params[:id] and @type = Type.find_by(url: params[:url]) and @type.visible)
      # Note: the id is not a number but it is the object custom url
      table = @type.name.capitalize.constantize
      @type_object = table.find_by(url: params[:id])
      @head_title = @type_object.title.capitalize
      render "template/#{@type.title}/show.html"
    else
      redirect_to root_path
    end
  end

  # Your custom actions

end
