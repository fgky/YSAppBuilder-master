server '222.76.217.201', :app, :web, :db, primary:true

set :domain, 'app.35nic.com'

set :rails_env, 'production'

set :user, 'yisence'

set :port, 22
set :deploy_to, "/home/#{user}/rails_apps/#{application}"
set :shared_path, "/home/#{user}/rails_apps/#{application}/shared"

set :branch, 'master'

