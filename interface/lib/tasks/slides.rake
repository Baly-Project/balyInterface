namespace :record do 
  desc "read all slides from DK api and save necessary data"
  task update: :environment do
    now=EnhancedTime.now
    updater=Updater.new
    logger=PrintLogger.new
    deleter=SafeDeleter.new
    deleter.clearDatabase
    begin
      data=updater.update(log:logger)
      logger.puts "Updated without errors, producing the following records:"
      data.each do |key,value|
	#if value.class.ancestors.include? OpenStruct
	  logger.puts JSON.pretty_generate(value.attributes)
        #end
      end
      logger.puts "Update Successful"
    rescue => e
      deleter.restoreDatabase
      logger.puts "Update unsuccessful with a #{e.class} stating #{e.message}, and the previous database has been restored" 
      logger.puts e.backtrace
    ensure
      logger.write(Rails.root.join("log","updatelogs","update_on_#{now.getFileAddon}.txt"))
      UpdateMailer.with(log:logger).update_email.deliver_now
    end
  end
end
