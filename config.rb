require 'digest/sha1'
require 'json'

class StockData
  def initialize
    @db = Sequel.connect(ENV['PRICE_DB_URL'])
  end

  def call(symbol, start_date, end_date)
    @db["""
      select 
        price_date,
        close 
      from 
        prices 
        inner join equities on prices.equity_id = equities.id
      where
        symbol = ? 
        and price_date between ? - '1 day'::interval and ?
    """, symbol, start_date, end_date].map { |r| [r[:price_date], r[:close]] }
  end
end

LedgerWeb::Config.new do |config|
  config.set :database_url, ENV['DATABASE_URL']
  config.set :index_report, :monthly_snapshot
  config.set :ledger_format, "%(quoted(xact.beg_line)),%(quoted(date)),%(quoted(payee)),%(quoted(account)),%(quoted(commodity(scrub(display_amount)))),%(quoted(quantity(scrub(display_amount)))),%(quoted(cleared)),%(quoted(virtual)),%(quoted(join(note | xact.note))),%(quoted(cost)),%(quoted(code)),%(quoted(filename))\n"
  config.set :ledger_columns, [ :xtn_id, :xtn_date, :note, :account, :commodity, :amount, :cleared, :virtual, :tags, :cost, :checknum, :filename ]  
  config.set :additional_view_directories, [File.join(File.dirname(__FILE__), 'views')]

  config.set :files_seen, {}
  config.set :file_count, 0

  config.add_hook :before_insert_row do |row|
    filename = row[:filename]
    unless config.get(:files_seen)[filename]
      count = config.get(:file_count)
      count += 1
      config.set(:file_count, count)
      config.get(:files_seen)[filename] = count
    end

    row[:commodity] = row[:commodity].gsub(/"/, '')

    row[:xtn_id] = row[:xtn_id].to_i + (config.get(:files_seen)[filename] * 1_000_000)

    tags_hash = {}
    row[:tags].strip.split('\n').each do |tag|
      k,v = tag.split(/:\s+/, 2)
      next if k.nil? || v.nil?

      k = k.strip
      v = v.strip
      tags_hash[k] = Float(v) rescue v
    end
    row[:jtags] = tags_hash.to_json

    reference_date = Date.new(2011, 4, 15)

    xtn_date = Date.strptime(row[:xtn_date], "%Y/%m/%d")

    row[:pay_period] = 2

    if xtn_date >= reference_date then
      if xtn_date.day <= 15
        row[:pay_period] = 1
      end
    else
      if xtn_date.day <= 6 or xtn_date.day >= 22 then
        row[:pay_period] = 1
      end
    end

    row

  end

  config.set :price_lookup_skip_symbols, ['$', 's']
  config.set :price_db, StockData.new
  config.set :price_function, lambda { |symbol, min_date, max_date| config.get(:price_db).call(symbol, min_date, max_date) }

  config.add_hook :after_load do |db|
    LedgerWeb::Database.load_prices
  end

  config.add_hook :before_load do |db|
    config.set :load_start, Time.now.utc
    d = Digest::SHA1.new
    puts "Calculating checksum"

    d.file(ENV['LEDGER_FILE'])

    config.set :checksum, d.hexdigest()
    puts "Done calculating checksum"
  end

  config.add_hook :after_load do |db|
    puts "Loading budget"

    db["delete from budget_periods"].delete

    path = File.join(File.dirname(ENV['LEDGER_FILE']), "budget_periods.csv")
    return unless File.exists?(path)

    CSV.foreach(path, :headers => true) do |row|
      db[:budget_periods].insert(row.to_hash)
    end

    puts "Done loading budget"
  end

  config.add_hook :after_load do |db|
    puts "Loading asset_allocation"

    db["delete from asset_allocation"].delete

    path = File.join(File.dirname(ENV['LEDGER_FILE']), "asset_allocation.csv")
    return unless File.exists?(path)

    CSV.foreach(path, :headers => true) do |row|
      db[:asset_allocation].insert(row.to_hash)
    end

    puts "Done loading asset_allocation"
  end  

  config.add_hook :after_load do |db|
    puts "Inserting update record"
    now = Time.now.utc
    start = config.get :load_start
    checksum = config.get :checksum

    puts "Doing insert"
    db[:update_history].insert(
      :updated_at => now,
      :num_seconds => now - start,
      :checksum => checksum
    )
    puts "Done Inserting Update Record"
  end

  config.add_hook :after_load do |db|
    puts "Updating xtn_week"
    db["update ledger set xtn_week = date_trunc('week', xtn_date)::date"].update
  end

  config.add_hook :after_load do |db|
    puts "Updating calendar"
    db["delete from calendar"].delete    
    db.run("insert into calendar select xtn_date, date_trunc('week', xtn_date)::date as xtn_week, date_trunc('month', xtn_date)::date as xtn_month, date_trunc('year', xtn_date)::date as xtn_year, to_char(xtn_date, 'ID')::integer as dow, to_char(xtn_date, 'W')::integer as wom, to_char(xtn_date, 'IW')::integer as woy from (select ('2007-01-01'::date + (x || ' days')::interval)::date as xtn_date from generate_series(0,20000) x) x")
  end

end
