set_default(:postgres_database) { "#{application}_production" }
set_default(:postgres_app_user) { application }
set_default(:postgres_app_password, 'ADD A PASSWORD HERE')

namespace :postgres do
  desc "Install the latest stable release of Postgres."
  task :install, roles: :db, only: {primary: true} do
    # run "#{sudo} apt-get -y update"
    # run "#{sudo} DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql postgresql-contrib libpq-dev"
    run "#{sudo} -u postgres psql -c \"CREATE ROLE #{user} SUPERUSER LOGIN PASSWORD '#{postgres_app_password}';\""
  end
end

