server '192.168.33.10', :app, :web, :db, primary:true

set :domain, 'packor.linjun.me'

set :rails_env, 'vagrant'

set :user, 'vagrant'

#set :port, 22
set :deploy_to, "/home/#{user}/rails_apps/#{application}"
set :shared_path, "/home/#{user}/rails_apps/#{application}/shared"

# Bonus! Colors are pretty!
def red(str)
  "\e[31m#{str}\e[0m"
end

# Figure out the name of the current local branch
def current_git_branch
  branch = `git symbolic-ref HEAD 2> /dev/null`.strip.gsub(/^refs\/heads\//, '')
  puts "Deploying branch #{red branch}"
  branch
end

# Set the deploy branch to the current branch
set :branch, current_git_branch

