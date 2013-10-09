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
  sh "env DATABASE_URL=postgres://ledger@192.168.1.14/ledger LEDGER_USERNAME=admin LEDGER_PASSWORD=foo LEDGER_PAYDAY_BENCHMARK=2013-01-18 EMERGENCY_FUND_TARGET=4 rackup -p 9595"
end

task :build_sales_transfers => :load_config do
  RATIOS = {
    '[Assets:Funds:Emergency]' => 0.3,
    '[Assets:Funds:Car]' =>       0.3
  }

  LedgerWeb::Database.handle.fetch("select max(xtn_date) as last_transfer from ledger where account = 'Assets:Sales:Checking' and amount < 0") do |row|
    last_transfer = row[:last_transfer] || Date.new(2013,9,29)
  end

  total_amount = 0

  LedgerWeb::Database.handle.fetch("select sum(amount) as amount from ledger where account = 'Assets:Sales:Checking' and amount > 0 and tags ~ 'sales: true'") do |row|
    total_amount = row[:amount]
  end

  today = Date.today.strftime('%Y/%m/%d')

  xfer_amount = total_amount * RATIOS.inject(0) { |s,kv| s + kv.last }

  xfer_rows = [
    "#{today} * Sales Transfer to Personal Checking",
    sprintf("    Assets:Schwab:Checking   $%0.2f", xfer_amount),
    "    Assets:Sales:Checking",
    "",
    "#{today} * Sales Transfer to Funds"
  ]

  RATIOS.each do |account, amount|
    xfer_amount = (total_amount * amount).to_f
    xfer_rows << sprintf("    %s    $%0.2f", account, xfer_amount)
  end

  xfer_rows << "    [Assets:Schwab:Checking]"

  puts xfer_rows.join("\n") + "\n"

end
