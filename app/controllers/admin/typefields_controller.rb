class Admin::TypefieldsController < Admin::AdminController
  before_action :control_user
  before_action :control_admin, only: [:new, :create]

  def index
    redirect_to admin_path
  end

  def show
    redirect_to admin_path
  end

  def new
    @types = Type.all
  end

  def create
    @typefield = Typefield.new(type_field: params[:type], name: params[:name].downcase, title: params[:title], type_id: params[:type_id], position: params[:position])
    if (@typefield.save)
      # add column to type for the new field
      table_name = Type.find(@typefield.type_id).name
      # create column to table for the default language
      ActiveRecord::Migration.add_column table_name, "#{@typefield.name}_#{I18n.default_locale}", :text
      # add traco code to model
      model_file = File.read("#{Rails.root}/app/models/#{table_name}.rb")
      new_string = "translates :#{@typefield.name} \n"
      new_string = new_string+"###### \n"
      updated_model_file = model_file.gsub(/######/, new_string)
      # To write changes to the file, use:
      File.open("#{Rails.root}/app/models/#{table_name}.rb", "w") {|file| file.puts updated_model_file }
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
      flash[:success] = $language['field_saved']
    else
      # output
      flash[:danger] = $language['field_not_saved']
      error_list = ""
      @typefield.errors.full_messages.each do |error|
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

end
