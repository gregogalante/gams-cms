namespace :config do

  task :start => :environment do

    puts "WELCOME TO GAMS CONFIGURATION".colorize(:yellow)
    puts "-----------------------------"

    puts "Starting configuration".colorize(:green)
    puts "-----------------------------"

    # Generate folders if they not exits
    Rake::Task['config:folders'].execute
    # Execute gams seeds in production
    Rake::Task['config:seeds'].execute

    puts "Finish configuration".colorize(:green)
    puts "-----------------------------"

  end

  task :folders => :environment do
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

  task :seeds => :environment do
    Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each do |filename|
      task_name = File.basename(filename, '.rb').intern
      task task_name => :environment do
        load(filename) if File.exist?(filename)
      end
    end
  end

end
