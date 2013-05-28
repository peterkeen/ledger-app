#-*-ruby-*-

require 'rubygems'
require 'ledger_web'

task :default => [:load]

task :load_config do
  LedgerWeb::Config.instance.load_user_config(File.dirname(__FILE__))
  LedgerWeb::Database.connect
end

task :load => :load_config do
  file = LedgerWeb::Database.dump_ledger_to_csv
  count = LedgerWeb::Database.load_database(file)
  puts "Loaded #{count} records"
end

task :migrate => :load_config do
  LedgerWeb::Database.run_migrations
end

task :server do
  sh "env DATABASE_URL=postgres://ledger@192.168.1.14/ledger LEDGER_USERNAME=admin LEDGER_PASSWORD=foo LEDGER_PAYDAY_BENCHMARK=2013-01-18 EMERGENCY_FUND_TARGET=4 rackup"
end
