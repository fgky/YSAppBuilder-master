namespace :nginx do
  desc 'Install latest stable release of nginx'
  task :install, roles: :web do
    run "#{sudo} add-apt-repository -y ppa:nginx/stable"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install nginx"
  end
  after 'deploy:install', 'nginx:install'

  desc 'setup nginx configuration for this application'
  task :setup, roles: :web do
    template 'nginx_unicorn.conf.erb', "#{shared_path}/nginx_conf"
    run "#{sudo} rm -rf /etc/nginx/sites-enabled/default"
    run "#{sudo} mv #{shared_path}/nginx_conf /etc/nginx/sites-enabled/#{application}.conf"
    restart
  end
  after 'deploy:setup', 'nginx:setup'

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end
end
