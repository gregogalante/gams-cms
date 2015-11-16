namespace :reset do

  task :start => :environment do

    puts "Do you want to delete all uploaded files? [y,n]"
    answer = STDIN.gets.chomp
    if(answer === "y")
      Rake::Task['reset:uploads'].execute
    end

    puts "Do you want to delete all pages template files? [y,n]"
    answer = STDIN.gets.chomp
    if(answer === "y")
      Rake::Task['reset:pages'].execute
    end

    puts "Do you want to delete all types model files? [y,n]"
    answer = STDIN.gets.chomp
    if(answer === "y")
      Rake::Task['reset:types'].execute
    end

    puts "Do you want to delete all custom seeds files? [y,n]"
    answer = STDIN.gets.chomp
    if(answer === "y")
      Rake::Task['reset:seeds'].execute
    end

    puts "Do you want to delete the development database? [y,n]"
    answer = STDIN.gets.chomp
    if(answer === "y")
      Rake::Task['reset:database'].execute
    end

    puts "Do you want to reset the config yaml file? [y,n]"
    answer = STDIN.gets.chomp
    if(answer === "y")
      Rake::Task['reset:config'].execute
    end

    puts "Do you want to reset the gams-migration files? [y,n]"
    answer = STDIN.gets.chomp
    if(answer === "y")
      Rake::Task['reset:gams_migration'].execute
    end

    puts "Do you want to reset the schema.rb file? [y,n]"
    answer = STDIN.gets.chomp
    if(answer === "y")
      Rake::Task['reset:schema'].execute
    end

    puts 'Now run rake db:setup'.colorize(:green)

    # Generate folders if they not exits
    directory_name = "#{Rails.root}/app/views/template"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    directory_name = "#{Rails.root}/app/views/template/pages"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    directory_name = "#{Rails.root}/db/gams-migrate"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    directory_name = "#{Rails.root}/db/gams-seeds"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)

  end

  task :schema => :environment do
    # copy gams-schema to official schema
    IO.copy_stream("#{Rails.root}/db/gams-schema.rb", "#{Rails.root}/db/schema.rb")
  end

  task :pages => :environment do
    # delete all pages template
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/app/views/template/pages/*"))
  end

  task :gams_migration => :environment do
    # delete all pages template
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/db/gams-migration/*"))
  end

  task :types => :environment do
    DEFAULT_MODELS = ['user.rb', 'note.rb', 'page.rb', 'field.rb', 'type.rb', 'typefield.rb']
    # delete all models of types
    files = Dir.glob("#{Rails.root}/app/models/*")
    files.each do |file|
      file_name = File.basename(file)
      file_is_default = false
      DEFAULT_MODELS.each do |default_model|
        if (default_model === file_name)
          file_is_default = true
          break
        end
      end
      if (!file_is_default)
        FileUtils.rm_rf(Dir.glob("#{Rails.root}/app/models/#{file_name}"))
      end
    end
    # delete all templates of types
    files = Dir.glob("#{Rails.root}/app/views/template/*")
    files.each do |file|
      file_name = File.basename(file)
      file_is_default = false
      DEFAULT_MODELS.each do |default_model|
        if ("pages" === file_name)
          file_is_default = true
          break
        end
      end
      if (!file_is_default)
        FileUtils.rm_rf(Dir.glob("#{Rails.root}/app/views/template/#{file_name}"))
      end
    end
  end

  task :database => :environment do
    # delete database files
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/db/development.sqlite3"))
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/db/test.sqlite3"))
  end

  task :uploads => :environment do
    # delete updated files
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/public/system"))
  end

  task :seeds => :environment do
    # delete seeds files
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/db/gams-seeds/*"))
  end

  task :config => :environment do
    # reset the config.yml file
    require 'yaml' # Built in, no gem required
    config = YAML::load_file("#{Rails.root}/config/config.yml") #Load
    config["app_name"] = "Gams"
    File.open("#{Rails.root}/config/config.yml", 'w') {|f| f.write config.to_yaml } #Store
    config["header_text"] = "Gams"
    File.open("#{Rails.root}/config/config.yml", 'w') {|f| f.write config.to_yaml } #Store
    config["footer_text"] = nil
    File.open("#{Rails.root}/config/config.yml", 'w') {|f| f.write config.to_yaml } #Store
    config["footer_url"] = nil
    File.open("#{Rails.root}/config/config.yml", 'w') {|f| f.write config.to_yaml } #Store
    config["has_languages"] = "false"
    File.open("#{Rails.root}/config/config.yml", 'w') {|f| f.write config.to_yaml } #Store
    config["languages_list"] = nil
    File.open("#{Rails.root}/config/config.yml", 'w') {|f| f.write config.to_yaml } #Store
  end

end
