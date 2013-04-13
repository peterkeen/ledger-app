require 'rubygems'
require 'capistrano-buildpack'

set :normalize_asset_timestamps, false
set :application, "ledger-app"
set :repository, "git@git.bugsplat.info:peter/ledger-app.git"
set :scm, :git
set :additional_domains, ['ledger.bugsplat.info']
set :use_ssl, true
set :use_sudo, true

role :web, "subspace.bugsplat.info"
set :buildpack_url, "git@git.bugsplat.info:peter/bugsplat-buildpack-ruby-simple"

set :user,        "peter"
set :app_user,    "ledger-web"
set :concurrency, "web=1"
set :base_port,   6500
set :use_ssl, true
set :force_ssl, true

read_env 'prod'

load 'deploy'



