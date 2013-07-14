set_default(:host_name, 'ADD HOSTNAME HERE') # without protocol, ex. mysite.com not http://mysite.com
set_default(:local_host_name, 'ADD HOSTNAME HERE') # without protocol, ex. mysite.com not http://mysite.com

namespace :postfix do
  desc "Install latest stable release of Postfix"
  task :install do
    run "#{sudo} apt-get -y update"
    run "#{sudo} DEBIAN_FRONTEND=noninteractive apt-get -y install postfix"
  end

  task :setup do
    temp_file = "/tmp/postfix_conf"
    run("hostname --fqd") do |ch, stream, data|
      host_name = data
    end
    local_host_name = host_name.split("\.")
    local_host_name[0] = "localhosts"
    local_host_name = local_host_name.join(".")
    set_default(:host_name, host_name)
    set_default(:local_host_name, local_host_name)
    template "postfix_main.erb", "/tmp/postfix_conf"
    run "#{sudo} mv #{temp_file} /etc/postfix/main.cf"
    run "#{sudo} /etc/init.d/postfix reload"
  end
end
