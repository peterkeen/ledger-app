Sequel.migration do
  up do
    create_table(:asset_allocation) do
      String :commodity
      Date :from_date
      Date :to_date
      Numeric :us_stock
      Numeric :us_bond
      Numeric :international_stock
      Numeric :international_bond
      Numeric :reit
    end
  end
end
