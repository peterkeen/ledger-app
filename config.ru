require 'rubygems'
require 'ledger_web'
require 'grack'
require 'rack/rewrite'

temp = Tempfile.new('ruby_inline', '/tmp')
dir = temp.path temp.delete
Dir.mkdir(dir, 0755)
ENV['INLINEDIR'] = dir 

LedgerWeb::Config.instance.load_user_config(File.dirname(__FILE__))
LedgerWeb::Database.connect

lib_dir = File.join(File.dirname(__FILE__), "lib")
$LOAD_PATH.unshift(lib_dir)
Dir[File.join(lib_dir, "*.rb")].each {|file| require File.basename(file) }

LedgerWeb::Application.set(:public_folder, File.join(File.dirname(__FILE__), 'public'))
ledger = LedgerWeb::Application.new

use Rack::Auth::Basic, 'Ledger' do |username, password|
  username == ENV['LEDGER_USERNAME'] && password == ENV['LEDGER_PASSWORD']
end

use Rack::Rewrite do
  r301 '/reports/dashboard', '/reports/_dashboard'
end

repo = Grack::App.new(
  project_root: ENV['PROJECT_ROOT'],
  upload_pack: true,
  receive_pack: true
)

run Rack::URLMap.new \
  '/repo' => repo,
  '/public' => Rack::File.new('./public'),
  '/files' => Rack::File.new('/usr/local/var/repos/financials'),
  '/' => ledger


