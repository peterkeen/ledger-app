#-*-ruby-*-

require 'rubygems'
require 'ledger_web'

task :default => [:load]

task :env do
  File.open('.env.prod').each do |line|
    key,val = line.strip.split('=', 2)
    ENV[key] = val
  end
end

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
  sh "env DATABASE_URL=postgres://ledger@192.168.1.100/ledger LEDGER_USERNAME=admin LEDGER_PASSWORD=foo LEDGER_PAYDAY_BENCHMARK=2013-01-18 EMERGENCY_FUND_TARGET=4 rackup -p 9595"
end

def one_row(query, bind_params=[])
  rows = []
  LedgerWeb::Database.handle.fetch(query, *bind_params) do |row|
    rows << row
  end
  rows.first
end

task :build_sales_transfers => [:env, :load_config] do

  total_transfer_amount = 0.6
  accounts = ENV['accounts'] || "car=0.3"

  ratios = accounts.split(/,/).inject({}) do |r, val|
    account, amount = val.split(':')
    r["[Assets:Funds:#{account.capitalize}]"] = amount.to_f
    r
  end

  ratio_amount = ratios.values.inject(0) { |s,v| s+=v }

  if ratio_amount > total_transfer_amount
    STDERR.puts "Error: total of account amounts cannot be higher than #{total_transfer_amount}"
    exit 1
  end

  emergency = total_transfer_amount - ratio_amount
  ratios['[Assets:Funds:Emergency]'] = emergency if emergency > 0

  last_transfer = one_row("select max(xtn_date) from ledger where account = 'Assets:Sales:Checking' and tags ~ 'transfer: true'")[:max]
  sales_since_last_transfer = one_row("select sum(amount) from ledger where account = 'Assets:Sales:Checking' and tags ~ 'sales: true' and xtn_date >= '#{last_transfer}'")[:sum]

  total_percent = ratios.values.inject(0){|s,v|s+=v}.to_f
  STDERR.puts last_transfer, sales_since_last_transfer.to_f, total_percent

  total_amount = sales_since_last_transfer * total_percent
  today = Date.today.strftime('%Y/%m/%d')

  xfer_rows = [
    "#{today} * Sales Transfer to Personal Checking",
    "    ; transfer: true",
    sprintf("    Assets:Schwab:Checking   $%0.2f", total_amount),
    "    Assets:Sales:Checking",
    "",
    "#{today} * Sales Transfer to Funds"
  ]

  ratios.each do |account, amount|
    xfer_amount = (sales_since_last_transfer * amount).to_f
    xfer_rows << sprintf("    %s    $%0.2f", account, xfer_amount)
  end

  xfer_rows << "    [Assets:Schwab:Checking]"

  puts xfer_rows.join("\n") + "\n"

end

# chase: bundle exec rake env reconcile fields=xtn_type:text,xtn_date:date,post_date:date,note:text,amount:numeric file=~/downloads/chase.csv account='Liabilities:Chase:SP' skip_first=true
# amex: bundle exec rake env reconcile fields=xtn_date:date,description:text,amount:numeric,note:text,address:text file=~/downloads/ofx.csv account='Liabilities:Amex' slop=2
# options: fields, file, account, slop, invert, skip_first

task :reconcile => :load_config do
  fields = ENV['fields']
  account = ENV['account']
  slop = (ENV['slop'] || 0).to_i
  invert = ENV['invert']
  skip_first = ENV['skip_first']


  h = LedgerWeb::Database.handle
  database_fields = fields.split(/,/).map do |field|
    field.split(/:/)
  end

  field_sql = database_fields.map { |f| f.join(' ') }.join(', ')
  h.run("create temporary table reconcile (#{field_sql})")

  line_num = 0

  CSV.foreach(ENV['file']) do |line|
    line_num += 1    
    next if line_num == 1 && skip_first
    h[:reconcile].insert(line)
  end


  puts "Checking for entries in reconcile not in ledger"

  h.fetch('select * from reconcile order by xtn_date') do |r|
    amount = r[:amount].to_f.round(2)
    amount = amount * -1 if invert
    start_date = r[:xtn_date] - slop
    end_date = r[:xtn_date] + slop

    query = "select count(1) from ledger where cleared and amount = #{amount} and account = '#{account}' and xtn_date between '#{start_date}' and '#{end_date}'"

    h.fetch(query) do |l|
      next unless l[:count] == 0

      amount = r[:amount].to_f.round(2)
      note = r[:note]
      date = r[:xtn_date]

      puts "#{date} #{note}    #{amount}    #{l[:count]}"
    end

  end

  dates = h.fetch('select min(xtn_date), max(xtn_date) from reconcile')

  puts "Checking for entries in ledger not in reconcile"

  h.fetch('select * from ledger where cleared and xtn_date between ? and ? and account = ? order by xtn_date', dates.first[:min], dates.first[:max], account) do |r|
    amount = r[:amount].to_f.round(2)
    amount = amount * -1 if invert
    start_date = r[:xtn_date] - slop
    end_date = r[:xtn_date] + slop

    query = "select count(1) from reconcile where amount = #{amount} and xtn_date between '#{start_date}' and '#{end_date}'"

    h.fetch(query) do |l|
      next unless l[:count] == 0
      amount = r[:amount].to_f.round(2)
      note = r[:note]
      date = r[:xtn_date]

      puts "#{date} #{note}    #{amount}    #{l[:count]}"
    end
    
  end
end
