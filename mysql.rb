set_default(:mysql_host, "localhost")
set_default(:mysql_root_password, 'ADD A PASSWORD HERE')
set_default(:mysql_app_user) { application }
set_default(:mysql_app_password, 'ADD A PASSWORD HERE')
set_default(:mysql_database) { "#{application}_production" }

namespace :mysql do
  desc "Install the latest stable release of Mysql."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} apt-get -y update"
    run "#{sudo} DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server mysql-client libmysqlclient-dev"
    run "mysqladmin -u root password '#{mysql_root_password}'"
  end

  task :install_client_only, roles: :app do
    run "#{sudo} apt-get -y update"
    run "#{sudo} DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-client libmysqlclient-dev"
  end
 # after "deploy:install", "mysql:install"

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    temp_file = "/tmp/#{application}_create.sql"
    run "rm -f #{temp_file}"
    run "touch #{temp_file}"
    run "echo \"GRANT USAGE ON *.* to #{mysql_app_user}@localhost identified by '#{mysql_app_password}';\" >> #{temp_file}"
    run "echo \"CREATE DATABASE #{mysql_database};\" >> #{temp_file}"
    run "echo \"GRANT ALL PRIVILEGES on #{mysql_database}.* to #{mysql_app_user}@localhost;\" >> #{temp_file}"
    run "mysql -u root -p'#{mysql_root_password}' < #{temp_file}"
    run "rm #{temp_file}"
  end

  after "mysql:setup", "mysql:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "mysql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "mysql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "mysql:symlink"

  desc "Pull a remote product db down to local dev db"
  task :pull do
    system "echo 'Pulling Remote DB'"
    temp_file = "/tmp/#{application}.sql"
    run "rm -f #{temp_file}"
    run "mysqldump -u root -p'#{mysql_root_password}' #{application}_production > #{temp_file}"
    download(temp_file, temp_file, :via => :scp)
    system "mysql -uroot #{application}_development < #{temp_file}"
    system "echo 'DB pulled successfully!'"
  end

  desc "Push a local dev db up to remote production db"
  task :push do
    temp_file = "/tmp/#{application}.sql"
    system "rm -f #{temp_file}"
    system "echo 'Creating mysql backup'"
    system "mysqldump -uroot #{application}_development > #{temp_file}"
    system "echo 'Mysql backup create, pushing...'"
    upload(temp_file, temp_file, :via => :scp)
    run "mysql -u root -p'#{mysql_root_password}' #{application}_production < #{temp_file}"
    system "echo 'Local db successfully pushed!'"
  end

   after "deploy:setup", "mysql:push"
end
