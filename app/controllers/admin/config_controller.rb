class Admin::ConfigController < Admin::AdminController
  before_action :control_user
  before_action :control_admin

  # STARTING GUIDE
  def guide

  end

  # DEVELOPMENT HELP
  def development

  end

  # LANGUAGES CONFIGURATION
  def language_configuration
    # get languages number value
    if($gams_config['has_languages'] === 'true')
      @has_languages = true
    else
      @has_languages = false
    end
    # load the languages.csv file
    require 'csv'
    @languages_name = []
    @languages_code = []
    CSV.foreach("#{Rails.root}/config/languages/languages.csv", :headers => true, :converters => :all, :col_sep =>',' ,:header_converters => lambda { |h| h.downcase.gsub(' ', '_') unless h.nil? }) do |row|
      lingua = row.to_hash
      nome = lingua['name'].capitalize
      code = lingua['code'].downcase
      @languages_name.push(nome)
      @languages_code.push(code)
    end
    # load current langauges
    @languages_list = $gams_config['languages_list']
  end

  def language_initialize # set site with
    # edit config.yml
    require 'yaml' # Built in, no gem required
    config = YAML::load_file("#{Rails.root}/config/config.yml") #Load
    # update has_languages
    if(params[:language_chose] === "true")
      config["has_languages"] = "true"
    else
      config["has_languages"] = "false"
    end
    File.open("#{Rails.root}/config/config.yml", 'w') {|f| f.write config.to_yaml } #Store
    # update languages_list
    if(params[:languages_list])
      languages = params[:languages_list].split(',')
      config["languages_list"] = languages
      File.open("#{Rails.root}/config/config.yml", 'w') {|f| f.write config.to_yaml } #Store
    end
    # get updated data of config.yml
    load_config_yaml()
    # initialize application for selected languages
    language_config_application()
    # output
    flash[:success] = "Site settings are updated"
    flash[:info] = "Please restart server to make it work fine"
    redirect_to admin_config_language_configuration_path
  end

  private def language_config_application
    # get languages list
    languages = $gams_config['languages_list']

    if(languages and languages.length > 0)
      # edit fields table
      languages.each do |language|
        # add langauges to fields
        if(!ActiveRecord::Base.connection.column_exists?(:fields, "value_#{language}"))
          ActiveRecord::Migration.add_column :fields, "value_#{language}", :text
        end
        # add languages to types
        Type.all.each do |type|
          table = type.name.capitalize.constantize
          # translate title
          if(!ActiveRecord::Base.connection.column_exists?(type.name, "title_#{language}"))
            ActiveRecord::Migration.add_column type.name, "title_#{language}", :string, :default => ' '
          end
          # translate fields
          typefields = Typefield.where(type_id: type.id)
          typefields.each do |typefield|
            typefield_db_type = table.column_for_attribute("#{typefield.name}_#{I18n.default_locale}").type
            if(!ActiveRecord::Base.connection.column_exists?(type.name, "#{typefield.name}_#{language}"))
              ActiveRecord::Migration.add_column type.name, "#{typefield.name}_#{language}", typefield_db_type
            end
          end
        end
      end
    end
  end

  # PAGE CONFIGURATION
  def page_new

  end

  def page_create
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
    redirect_to admin_settings_path
  end

  # FIELD CONFIGURATION
  def field_new
    @pages = Page.all
  end

  def field_create
    @field = Field.new(type_field: params[:type], name: params[:name].downcase, title: params[:title], page_id: params[:page], position: params[:position])
    if (@field.save)
      # output
      flash[:success] = "The new field #{@field.title} is saved"
    else
      # output
      flash[:danger] = "Sorry, the new field is not saved"
      error_list = ""
      @field.errors.full_messages.each do |error|
        error_list += " #{error}, "
      end
      flash[:warning] = error_list[0...-2]
    end
    redirect_to admin_settings_path
  end

  # REPEATER CONFIGURATION
  def repeater_new
    @pages = Page.all
    @types = Type.all
  end

  def repeater_create
    @field = Field.new(type_field: params[:type], name: params[:name].downcase, title: params[:title], page_id: params[:page], repeating: params[:repeating], position: params[:position])
    if (@field.save)
      # output
      flash[:success] = "The new repeater #{@field.title} is saved"
    else
      # output
      flash[:danger] = "Sorry, the new repeater is not saved"
      error_list = ""
      @field.errors.full_messages.each do |error|
        error_list += " #{error}, "
      end
      flash[:warning] = error_list[0...-2]
    end
    redirect_to admin_settings_path
  end


  # TYPE CONFIGURATION
  def type_new

  end

  def type_create
    @type = Type.new(name: params[:title_s].downcase, title_s: params[:title_s].downcase, title_p: params[:title_p].downcase, url: params[:url].downcase, visible: params[:visible])
    if(@type.save)
      # dynamic creation of the type table
      ActiveRecord::Migration.create_table @type.name.downcase do |t|
        t.string "url"
        t.string "title_#{I18n.default_locale}"
        # check multilanguage
        if($gams_config[:has_languages] === 'true' )
          if (@languages_list)
            @languages_list.each do |code|
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
    redirect_to admin_settings_path
  end

  # TYPEFIELD CONFIGURATION
  def typefield_new
    @types = Type.all
  end

  def typefield_create
    @typefield = Typefield.new(type_field: params[:type], name: params[:name].downcase, title: params[:title], type_id: params[:type_id], position: params[:position])
    if (@typefield.save)
      # add column to type for the new field
      table_name = Type.find(@typefield.type_id).name
      # create column for default languages
      if(@typefield.type_field === "file" or @typefield.type_field === "image")
        ActiveRecord::Migration.add_column table_name, "#{@typefield.name}_file_name", :string
        ActiveRecord::Migration.add_column table_name, "#{@typefield.name}_content_type", :string
        ActiveRecord::Migration.add_column table_name, "#{@typefield.name}_file_size", :integer
        ActiveRecord::Migration.add_column table_name, "#{@typefield.name}_updated_at", :datetime
        # add paperclip code to model
        model_file = File.read("#{Rails.root}/app/models/#{table_name}.rb")
        if(@typefield.type_field === "image")
          new_string = "has_attached_file :#{@typefield.name}, styles: { medium: '800x800>', thumb: '250x250>' } \n"
        else
          new_string = "has_attached_file :#{@typefield.name} \n"
        end
        new_string = new_string+"do_not_validate_attachment_file_type :#{@typefield.name} \n"
        new_string = new_string+"###### \n"
        updated_model_file = model_file.gsub(/######/, new_string)
        # To write changes to the file, use:
        File.open("#{Rails.root}/app/models/#{table_name}.rb", "w") {|file| file.puts updated_model_file }
      else
        # create column to table for the default language
        ActiveRecord::Migration.add_column table_name, "#{@typefield.name}_#{I18n.default_locale}", :text
        # add traco code to model
        model_file = File.read("#{Rails.root}/app/models/#{table_name}.rb")
        new_string = "translates :#{@typefield.name} \n"
        new_string = new_string+"###### \n"
        updated_model_file = model_file.gsub(/######/, new_string)
        # To write changes to the file, use:
        File.open("#{Rails.root}/app/models/#{table_name}.rb", "w") {|file| file.puts updated_model_file }
      end
      # create column for others languages
      if($gams_config['has_languages'] === "true")
        languages = $gams_config['languages_list']
        if(languages and languages.length > 0)
          languages.each do |language|
            # add column to table for each language
            ActiveRecord::Migration.add_column table_name, "#{@typefield.name}_#{language}", :text
          end
        end
      end
      # output
      flash[:success] = "The new typefield #{@typefield.title} is saved"
    else
      # output
      flash[:danger] = "Sorry, the new field is not saved"
      error_list = ""
      @typefield.errors.full_messages.each do |error|
        error_list += " #{error}, "
      end
      flash[:warning] = error_list[0...-2]
    end
    redirect_to admin_settings_path
  end

end
