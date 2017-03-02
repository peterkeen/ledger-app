require 'rubygems'
require 'capistrano-buildpack'

set :normalize_asset_timestamps, false
set :application, "ledger-app"
set :repository, "git@git.zrail.net:peter/ledger-app.git"
set :scm, :git
set :additional_domains, ['ledger.bugsplat.info']
set :use_sudo, true

role :web, "kodos.zrail.net"
set :buildpack_url, "git@git.zrail.net:peter/bugsplat-buildpack-ruby-shared"

set :user,        "peter"
set :concurrency, "web=1,load=1"
set :base_port,   6500
set :use_ssl, true
set :force_ssl, false
set :listen_address, '10.248.9.84'

read_env 'prod'

load 'deploy'



