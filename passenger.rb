namespace :passenger do
  desc "Install Passenger"
  task :install, roles: :app do
    run "sudo apt-get -y install libcurl4-openssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev"
    run "sudo gem install passenger --no-ri --no-rdoc"
    run "sudo passenger-install-apache2-module --auto"

    version = 'ERROR' # default
    run("gem list | grep passenger") do |ch, stream, data|
      version = data.sub(/passenger \(([^,]+).*?\)/,"\\1").strip
    end
    puts "  passenger version #{version} configured"

    passenger_config =<<-EOF
    LoadModule passenger_module /usr/local/lib/ruby/gems/1.9.1/gems/passenger-#{version}/ext/apache2/mod_passenger.so
    PassengerRoot /usr/local/lib/ruby/gems/1.9.1/gems/passenger-#{version}
    PassengerRuby /usr/local/bin/ruby
    EOF

    put passenger_config, "/tmp/passenger"
    run "#{sudo} mv /tmp/passenger /etc/apache2/conf.d/passenger"
    run "#{sudo} apache2ctl restart"

  end
end

#after "deploy:install", "passenger:install"
