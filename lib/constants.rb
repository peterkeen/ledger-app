module Constants
  CURRENT_ACCOUNTS = '(Assets:PNC|Liabilities:Chase|Assets:BofA|Assets:Schwab|Assets:Amex|Assets:SelectAccount:HSA)'
  LONG_TERM_FUNDS  = 'Assets:Funds:(Travel|House|Furniture|Emergency|Reserve|Bike|Car|Medical|Stash|Schmoop|Abigail)'
  LONG_TERM_LIABILITIES = 'Liabilities:(Loans|PNC:HELOC)'
  LIQUID_TICKERS   = 'VASIX|\$'
end

LedgerWeb::Database.handle.logger = Logger.new($stdout)
