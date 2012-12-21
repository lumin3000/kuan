# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :sphinx, "cd :path && RAILS_ENV=:environment PATH=/usr/local/coreseek/bin:$PATH INDEX_ONLY=true rake :task :output"

every 1.day, :at => '2:30am'  do
  set :output, "log/sphinx_index.log"
  sphinx "mongoid_sphinx:index"
end

every 1.day, :at => '4:30am' do
  runner "Post.accumulate_for_tags"
end

#every 6.hours do
#  runner "Feed.transfer_all"
#end
