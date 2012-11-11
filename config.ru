require 'rubygems'
require 'ledger_web'

LedgerWeb::Config.instance.load_user_config(File.dirname(__FILE__))
LedgerWeb::Database.connect

lib_dir = File.join(File.dirname(__FILE__), "lib")
$LOAD_PATH.unshift(lib_dir)
Dir[File.join(lib_dir, "*.rb")].each {|file| require File.basename(file) }

ledger = LedgerWeb::Application.new

protected_ledger = Rack::Auth::Basic.new(ledger) do |username, password|
  username == ENV['LEDGER_USERNAME'] && password == ENV['LEDGER_PASSWORD']
end

run protected_ledger
