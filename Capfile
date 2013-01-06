require 'rubygems'

set :application, "ledger-app"
set :repository, "git@git.bugsplat.info:peter/bugsplat.git"
set :scm, :git
set :additional_domains, ['ledger.bugsplat.info']

role :web, "subspace.bugsplat.info"
set :buildpack_url, "git@git.bugsplat.info:peter/bugsplat-buildpack-ruby-simple"

set :user, "peter"
set :base_port, 6500
set :concurrency, "web=1"

set :deploy_env, {
  'LANG' => 'en_US.UTF-8',
  'PATH' => 'bin:vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin',
  'GEM_PATH' => 'vendor/bundle/ruby/1.9.1:.',
  'RACK_ENV' => 'production',
  'REMOTE_SYSLOG_URI' => 'syslog://logs.papertrailapp.com:49211',
}

load 'deploy'
require 'capistrano-buildpack'


