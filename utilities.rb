# Capistrano::Configuration.instance(:must_exist).load do
#   desc "tail production log files"
#   task :tail_logs, :roles => :app do
#     run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
#       puts # for an extra line break before the host name
#       puts "#{channel[:host]}: #{data}"
#       break if stream == :err
#     end
#   end
# end

namespace :db do
  desc "Pull a remote product db down to local dev db"
  task :pull do
    mysql::pull
  end

  desc "Push a local dev db up to remote production db"
  task :push do
    mysql::push
  end
end

# desc "Displays the production log from the server locally"
task :tail, :roles => :app do
  stream "tail -500f #{current_path}/log/production.log"
end
