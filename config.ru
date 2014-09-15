require 'rubygems'
require 'ledger_web'
require 'grack'

LedgerWeb::Config.instance.load_user_config(File.dirname(__FILE__))
LedgerWeb::Database.connect

lib_dir = File.join(File.dirname(__FILE__), "lib")
$LOAD_PATH.unshift(lib_dir)
Dir[File.join(lib_dir, "*.rb")].each {|file| require File.basename(file) }

ledger = LedgerWeb::Application.new

use Rack::Auth::Basic, 'Ledger' do |username, password|
  username == ENV['LEDGER_USERNAME'] && password == ENV['LEDGER_PASSWORD']
end

repo = Grack::App.new(
  project_root: ENV['PROJECT_ROOT'],
  upload_pack: true,
  receive_pack: true,
  hooks: {
    receive_pack: lambda do
      Thread.new do
        LedgerWeb::Database.handle.transaction do
          Dir.chdir File.join(ENV['PROJECT_ROOT'], '..') do
            unless File.directory? 'clone'
              system("git clone #{File.join(ENV['PROJECT_ROOT'], 'ledger.git')} clone")
            else
              Dir.chdir('clone') do
                system("git pull origin master")
              end
            end
          end
          LedgerWeb::Config.instance.load_user_config(File.dirname(__FILE__))
          LedgerWeb::Database.connect
          file = LedgerWeb::Database.dump_ledger_to_csv
          count = LedgerWeb::Database.load_database(file)
          puts "Loaded #{count} records"
        end
      end
    end
  }
)

run Rack::URLMap.new \
  '/' => ledger,
  '/repo' => repo,
  '/public' => Rack::File.new('./public'),
  '/files' => Rack::File.new('/usr/local/var/repos/financials')
