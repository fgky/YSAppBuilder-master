set :rvm_ruby_string, :local
set :rvm_autolibs_flag, "enabled"        # more info: rvm help autolibs
set :rvm_install_with_sudo, true

before 'deploy:install', 'rvm:install_rvm'
before 'deploy:install', 'rvm:install_ruby'

require "rvm/capistrano"
