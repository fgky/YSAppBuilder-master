namespace :nodejs do
  desc 'Install nodejs'
  task :install, roles: :app do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install nodejs"
  end
  after 'deploy:install', 'nodejs:install'
end
