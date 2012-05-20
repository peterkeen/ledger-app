require 'rubygems'
require 'ledger_web'

LedgerWeb::Config.instance.load_user_config(File.dirname(__FILE__))
LedgerWeb::Database.connect

ledger = LedgerWeb::Application.new

protected_ledger = Rack::Auth::Basic.new(ledger) do |username, password|
  username == ENV['LEDGER_USERNAME'] && password == ENV['LEDGER_PASSWORD']
end

run protected_ledger
