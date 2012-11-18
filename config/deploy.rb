require 'digest/sha1'

set :application, "ledger"
set :repository,  "git@git.bugsplat.info:peter/ledger-app.git"
set :scm, :git


default_run_options[:pty] = true
default_run_options[:shell] = '/bin/bash'


task :prod do
  role :web, "lionel.local"                          # Your HTTP server, Apache/etc
  role :db,  "lionel.local", :primary => true # This is where Rails migrations will run

  set :deploy_to, "/Users/peter/apps/ledger"
  set :foreman_export_path, "/Users/peter/Library/LaunchAgents"
  set :foreman_export_type, "launchd"

  set :user, "peter"
  set :base_port, 6500

  set :buildpack_url, "https://github.com/peterkeen/heroku-buildpack-ruby"
end

task :stage do
  role :web, "appvm"
  role :db, "appvm", :primary => true

  set :deploy_to, "/apps/ledger"
  set :user, "vagrant"
  set :base_port, 6500

  set :buildpack_url, "git@git.bugsplat.info:peter/heroku-buildpack-ruby"

  set :foreman_export_path, "/etc/init"
  set :foreman_export_type, "upstart"
end


# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

after "deploy:setup" do
  sudo "chown -R #{user} #{deploy_to}"
end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end


before "deploy" do

  set :buildpack_hash, Digest::SHA1.hexdigest(buildpack_url)
  set :buildpack_path, "#{shared_path}/buildpack-#{buildpack_hash}"
  set :concurrency, "web=1"

  set :deploy_env, {
    'DATABASE_URL' => 'postgres://ledger@192.168.1.14/ledger',
    'EMERGENCY_FUND_TARGET' => 4,
    'LEDGER_FILE' => '/usr/local/var/repos/financials/ledger.txt',
    'LEDGER_USERNAME' => 'admin',
    'LEDGER_PASSWORD' => 'bugsplat1234',
    'LANG' => 'en_US.UTF-8',
    'PATH' => 'bin:vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin',
    'GEM_PATH' => 'vendor/bundle/ruby/1.9.1',
    'RACK_ENV' => 'production',
  }

  run("[[ ! -e #{buildpack_path} ]] && git clone #{buildpack_url} #{buildpack_path}; exit 0")
  run("cd #{buildpack_path} && git fetch origin && git reset --hard origin/master")
  run("mkdir -p #{shared_path}/build_cache")
end

before "deploy:finalize_update" do
  run("cd #{buildpack_path} && bin/compile #{release_path} #{shared_path}/build_cache")

  env_lines = []
  deploy_env.each do |k,v|
    env_lines << "#{k}=#{v}"
  end
  env_contents = env_lines.join("\n") + "\n"

  put(env_contents, "#{release_path}/.env")
end

namespace :deploy do
  task :restart do
    sudo "launchctl unload -wF #{foreman_export_path}/ledger-web-1.plist; true"
    sudo "foreman export #{foreman_export_type} #{foreman_export_path} -d #{release_path} -l /var/log/#{application} -a #{application} -u #{user} -p #{base_port} -c #{concurrency}"
    sudo "launchctl load -wF #{launchd_conf_path}/ledger-web-1.plist; true"
  end
end
