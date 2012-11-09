Sequel.migration do
  up do
    create_table(:budget_periods) do
      String :account
      BigDecimal :amount
      Date :from_date
      Date :to_date
    end

    create_or_replace_view :budget_months, "select xtn_month, account, amount from (select distinct xtn_month from accounts_months) x cross join budget_periods where xtn_month between budget_periods.from_date and (coalesce(budget_periods.to_date, now()::date))"
  end
  down do
    drop_view :budget_months
    drop_table :budget_periods
  end
end
