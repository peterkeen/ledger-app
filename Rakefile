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

