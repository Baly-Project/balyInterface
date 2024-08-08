namespace :record do 
  desc "read all slides from DK api and save necessary data"
  task update: :environment do 
    manager=Updater.new
    data=manager.update
    puts data
  end
end
