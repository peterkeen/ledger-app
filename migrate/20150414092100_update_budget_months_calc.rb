Sequel.migration do
  up do
    create_or_replace_view :budget_months, "select xtn_month::date, account, amount from (select '2007-01-01'::date + (x.x || ' months')::interval as xtn_month from generate_series(0,(select 12 * extract('years' from age('2007-01-01'::date)) + extract('months' from age('2007-01-01'::date)) + 60)::integer) x ) x cross join budget_periods where xtn_month between budget_periods.from_date and (coalesce(budget_periods.to_date, now()::date + '5 years'::interval))"
  end

  down do
    create_or_replace_view :budget_months, "select xtn_month, account, amount from (select distinct xtn_month from accounts_months) x cross join budget_periods where xtn_month between budget_periods.from_date and (coalesce(budget_periods.to_date, now()::date))"
  end
end
