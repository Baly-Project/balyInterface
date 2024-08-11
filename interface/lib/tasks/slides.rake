namespace :record do 
  desc "read all slides from DK api and save necessary data"
  task update: :environment do
    now=EnhancedTime.now
    updater=Updater.new
    deleter=SafeDeleter.new
    deleter.clearDatabase
    logfile=File.new(Rails.root.join("log","updatelogs","update_on_#{now.getFileAddon}.txt"),"w")
    begin 
      data=updater.update
      logfile.puts "Updated without errors, producing the following records:"
      logdata=String.new
      data.each do |key,value|
	#if value.class.ancestors.include? OpenStruct
	  logfile.puts JSON.pretty_generate(value.attributes)
        #end
      end
      logfile.puts logdata
      puts "Update Successful"
    rescue => e
      deleter.restoreDatabase
      puts "Update unsuccessful with a #{e.class} stating #{e.message}, and the previous database has been restored" 
    ensure
      logfile.close
    end      
  end
end
