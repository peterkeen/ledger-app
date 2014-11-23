require 'rubygems'
require 'capistrano-buildpack'

set :normalize_asset_timestamps, false
set :application, "ledger-app"
set :repository, "git@git.bugsplat.info:peter/ledger-app.git"
set :scm, :git
set :additional_domains, ['ledger.bugsplat.info']
set :use_sudo, true

role :web, "kodos.zrail.net"
set :buildpack_url, "git@git.bugsplat.info:peter/bugsplat-buildpack-ruby-simple"

set :user,        "peter"
set :concurrency, "web=1,load=1"
set :base_port,   6500
set :use_ssl, true
set :force_ssl, false

read_env 'prod'

load 'deploy'



