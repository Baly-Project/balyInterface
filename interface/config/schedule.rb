# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#

 env :PATH, ENV['PATH']
# Change before deployment
 set :environment, "development"
 set :output, "./log/cron_log.log"
#
# The time is in GMT, which is 7 hours ahead of Eastern (kenyon) time
 every :monday, at: '11:00 am' do
   rake "record:update"
 end

 #every 1.minutes do 
 #  runner "puts 'Hello World'"
 #end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
