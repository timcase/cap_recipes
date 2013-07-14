def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end
desc "tail production log"
task :tail_log, :roles => :app do
  run "tail -100f #{shared_path}/log/production.log" do |channel, stream, data|
    trap("INT") { puts 'Interupted'; exit 0; }
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

desc "Remote console"
task :console, :roles => :app do
  env = "production"
  server = find_servers(:roles => [:app]).first
  run_with_tty server, %W( ./script/rails console #{env} )
end

desc "Remote dbconsole"
task :dbconsole, :roles => :app do
  env = "production"
  server = find_servers(:roles => [:app]).first
  run_with_tty server, %W( ./script/rails dbconsole #{env} )
end

def run_with_tty(server, cmd)
  # looks like total pizdets
  command = []
  command += %W( ssh -t #{gateway} -l #{self[:gateway_user] || self[:user]} ) if     self[:gateway]
  command += %W( ssh -t )
  command += %W( -p #{server.port}) if server.port
  command += %W( -l #{user} #{server.host} )
  command += %W( cd #{current_path} )
  # have to escape this once if running via double ssh
  command += [self[:gateway] ? '\&\&' : '&&']
  command += Array(cmd)
  system *command
end


namespace :deploy do
  desc "Set user accounts on server"
  task :set_users do
    server = find_servers(:roles => [:app]).first
    config_user = user
    set :user, "root"
    template "sudoers.erb", "/tmp/sudoers"
    run "mv /tmp/sudoers /etc/sudoers"
    run "chmod 0440 /etc/sudoers"
    run "adduser deploy --ingroup admin --disabled-password --gecos \"\""
    run "mkdir /home/deploy/.ssh"
    run "chown deploy:admin /home/deploy/.ssh"
    system("scp ~/.ssh/id_dsa.pub root@#{server}:/home/deploy/.ssh/authorized_keys")
    #
    # system("echo "" >> ~/.ssh/config")
    # system("echo \"Host #{application}\" >> ~/.ssh/config")
    # system("echo \"Hostname #{oles[:app].servers.first}\" >> ~/.ssh/config")
    set :user, config_user
  end

  desc "Install everything onto the server"
  task :install do
    ubuntu::install
    apache::install
    mysql::install
    ruby::install
    passenger::install
    postfix::setup
  end

end
