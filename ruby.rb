set_default :ruby_version, "1.9.3-p362"

namespace :ruby do
  desc "Install Ruby, and the Bundler gem"
  task :install, roles: :app do
    run "#{sudo} apt-get -y install build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev libyaml-dev"
    run "wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-#{ruby_version}.tar.gz"
    run "tar -xvzf ruby-#{ruby_version}.tar.gz"
    run "cd ruby-#{ruby_version}; ./configure --prefix=/usr/local"
    run "cd ruby-#{ruby_version}; make"
    run "cd ruby-#{ruby_version}; #{sudo} make install"
    run "#{sudo} gem install bundler --no-ri --no-rdoc"
    run "#{sudo} gem install rails --no-ri --no-rdoc"
  end
end

#after "deploy:install", "ruby:install"

