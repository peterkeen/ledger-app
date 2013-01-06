require 'rubygems'

set :application, "ledger-app"
set :repository, "git@git.bugsplat.info:peter/ledger-app.git"
set :scm, :git
set :additional_domains, ['ledger.bugsplat.info']

role :web, "subspace.bugsplat.info"
set :buildpack_url, "git@git.bugsplat.info:peter/bugsplat-buildpack-ruby-simple"

set :user, "peter"
set :base_port, 6500
set :concurrency, "web=1"

read_env 'prod'

load 'deploy'
require 'capistrano-buildpack'


