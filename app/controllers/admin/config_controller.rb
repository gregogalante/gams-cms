class Admin::ConfigController < Admin::AdminController
  before_action :control_user
  before_action :control_admin

  # STATIC PAGES
  def home

  end

  def guide

  end

  def development

  end

  # GENERAL SETTINGS
  def settings
    # get updated data of config.yml
    load_config_yaml()
  end

  def update_settings
    require 'yaml' # Built in, no gem required
    config = YAML::load_file("#{Rails.root}/config/config.yml") #Load
    # Site name
    if(params[:header_text])
      config['header_text'] = params[:header_text]
    end
    if(params[:footer_text])
      config['footer_text'] = params[:footer_text]
    end
    if(params[:footer_url])
      config['footer_url'] = params[:footer_url]
    end
    File.open("#{Rails.root}/config/config.yml", 'w') {|f| f.write config.to_yaml }
    # get updated data of config.yml
    load_config_yaml()
    # output
    flash[:success] = $language['setting_updated']
    redirect_to admin_configuration_path
  end

  # MIGRATION GENERATOR
  def generate_migration
    # generate folders if they don't exist
    directory_name = "#{Rails.root}/app/views/template"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    directory_name = "#{Rails.root}/app/views/template/pages"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    directory_name = "#{Rails.root}/db/gams-migrate"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    directory_name = "#{Rails.root}/db/gams-seeds"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    # delete old gams_seeds files
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/db/gams-seeds/*"))
    # generate new gams_seeds file
    File.open("#{Rails.root}/db/gams-seeds/gams_seeds.rb", "a") do |page|
      # generate pages seeds
      page.write("# DEFAULT PAGES \n")
      @pages = Page.all
      @pages.each do |object_page|
        page.write('Page.create(title: "'+"#{object_page.title}"+'", url: "'+"#{object_page.url}"+'")'+"\n")
      end
      # generate fields seeds
      page.write("# DEFAULT FIELDS \n")
      @fields = Field.all
      @fields.each do |object_field|
        page.write('Field.create(type_field: "'+"#{object_field.type_field}"+'", name: "'+"#{object_field.name}"+'", title: "'+"#{object_field.title}"+'", repeating: "'+"#{object_field.repeating}"+'", page_id: "'+"#{object_field.page_id}"+'", position: "'+"#{object_field.position}"+'")'+"\n")
      end
      # generate types seeds
      page.write("# DEFAULT TYPES \n")
      @types = Type.all
      @types.each do |object_type|
        page.write('Type.create(name: "'+"#{object_type.name}"+'", title_s: "'+"#{object_type.title_s}"+'", title_p: "'+"#{object_type.title_p}"+'", url: "'+"#{object_type.url}"+'", visible: '+"#{object_type.visible}"+')'+"\n")
      end
      # generate typefields seeds
      page.write("# DEFAULT TYPEFIELDS \n")
      @typefields = Typefield.all
      @typefields.each do |object_typefield|
        page.write('Typefield.create(type_field: "'+"#{object_typefield.type_field}"+'", name: "'+"#{object_typefield.name}"+'", title: "'+"#{object_typefield.title}"+'", type_id: "'+"#{object_typefield.type_id}"+'", position: "'+"#{object_typefield.position}"+'")'+"\n")
      end
    end
    # delete old migrations files
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/db/gams-migrate/*"))
    # generate new migration file
    Type.all.each do |type|
        File.open("#{Rails.root}/db/gams-migrate/#{Time.now.to_s(:number)}_create_#{type.name.downcase}.rb", "w+") do |page|
          page.write("class Create#{type.name.capitalize} < ActiveRecord::Migration \n   def change \n ")
          page.write("  create_table :#{type.name.downcase} do |t| \n    t.timestamps null: false \n")
            #Get tables
            table = type.name.capitalize.constantize
            table_list = table.new.attribute_names.to_a
            table_list.each do |table|
              if(table != 'id' && table != 'created_at' && table != 'updated_at')
                page.write("    t.text '#{table}' \n")
              end
            end
          page.write("   end \n end\nend")
        end
    end
    flash[:success] = "Yeah DEV. Go in production ;)"
    redirect_to admin_configuration_path
  end

  # LANGUAGES CONFIGURATION
  def languages
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

  def languages_initialize # set site with
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
    languages_config_application()
    # output
    flash[:success] = $language['setting_updated']
    flash[:info] = $language['server_restart_required']
    redirect_to admin_config_languages_path
  end

  private def languages_config_application
    # get languages list
    languages = $gams_config['languages_list']

    if(languages and languages.length > 0)
      # edit fields table
      languages.each do |language|
        # add langauges to images
        if(!ActiveRecord::Base.connection.column_exists?(:images, "title_#{language}"))
          ActiveRecord::Migration.add_column :images, "title_#{language}", :string
        end
        if(!ActiveRecord::Base.connection.column_exists?(:images, "description_#{language}"))
          ActiveRecord::Migration.add_column :images, "description_#{language}", :text
        end
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

end
