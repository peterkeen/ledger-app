module Constants
  CURRENT_ACCOUNTS = '(Assets:PNC|Liabilities:Chase|Assets:BofA|Assets:Schwab|Assets:Amex|Assets:SelectAccount)'
  LONG_TERM_FUNDS  = 'Assets:Funds:(Travel|House|Furniture|Emergency|Reserve|Bike|Car|Medical|Stash|Schmoop|Abigail)'
  LONG_TERM_LIABILITIES = 'Liabilities:(Loans|PNC:HELOC)'
  LIQUID_TICKERS   = 'VASIX|SWTSX|\$'
end

if ENV['RACK_ENV'] != 'production'
  LedgerWeb::Database.handle.logger = Logger.new($stdout)
end
