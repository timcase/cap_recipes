namespace :ubuntu do
  desc "install ubuntu prerequisites"
  task :install do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install python-software-properties git-core"
    run "#{sudo} apt-get -y install libxml2 libxml2-dev libxslt1-dev"
    run "#{sudo} apt-get -y install libcurl3 libcurl3-gnutls libcurl4-openssl-dev"
    run "#{sudo} apt-get -y install libmagickwand-dev imagemagick"
    run "#{sudo} DEBIAN_FRONTEND=noninteractive apt-add-repository ppa:chris-lea/node.js"
    run "#{sudo} apt-get -y update"
    run "#{sudo} DEBIAN_FRONTEND=noninteractive apt-get -y install nodejs npm"
  end
end
