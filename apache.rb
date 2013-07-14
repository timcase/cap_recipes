set_default(:use_ssl, true)
namespace :apache do
  desc "Install latest stable release of apache"
  task :install, roles: :web do
   run "#{sudo} apt-get -y update"
   run "#{sudo} apt-get -y install apache2"
   run "#{sudo} a2enmod rewrite"
   run "#{sudo} a2enmod ssl" if use_ssl
   run "#{sudo} groupadd www-pub"
   run "#{sudo} usermod -a -G www-pub deploy"
   run "#{sudo} chown -R root:www-pub /var/www"
   run "#{sudo} find /var/www -type d -exec chmod 2775 {} \\;"
   run "#{sudo} find /var/www -type f -exec chmod 0664 {} \\;"
   run "#{sudo} rm /var/www/index.html"
  end

#  after "deploy:install", "apache:install"

  desc "Setup apache configuration for this application"
  task :setup, roles: :web do
    template "apache.erb", "/tmp/apache_conf"
    run "#{sudo} mv /tmp/apache_conf /etc/apache2/sites-available/#{application}"
    run "#{sudo} a2ensite #{application}"
  end
  after "deploy:setup", "apache:setup"

  %w[start stop restart].each do |command|
    desc "#{command} apache"
    task command, roles: :web do
      run "#{sudo} apache2ctl #{command}"
    end
  end
end
