require 'capistrano/ext/multistage'
require 'capistrano_colors'

require 'bundler/capistrano'

require 'sidekiq/capistrano'

set :application, 'YSAppBuilder'
set :user, 'deployer'

set :stages, %w(vagrant staging production)
set :default_stage, 'vagrant'

set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository, 'git@github.com:Sumi-Interactive/YSAppBuilder.git'
set :scm_verbose, true
set :checkout, 'export'

set :bundle_without, [:test, :development]

default_run_options[:pty] = true
set :ssh_options, { forward_agent: true }

after 'deploy', 'deploy:cleanup' # keep only last 5 release

load 'config/recipes/base'
load 'config/recipes/rvm'
load 'config/recipes/nginx'
load 'config/recipes/postgresql'
load 'config/recipes/nodejs'
load 'config/recipes/unicorn'
load 'config/recipes/android_sdk'

