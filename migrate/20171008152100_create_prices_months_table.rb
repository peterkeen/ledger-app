Sequel.migration do
  up do
    create_table(:prices_months) do
      Date :xtn_month
      String :symbol
      BigDecimal :amount
    end
  end
end
