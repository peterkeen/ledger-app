Sequel.migration do
  up do
    create_or_replace_view :budget_months, "select xtn_month, account, amount, wom from (select xtn_month, wom::integer from calendar where dow = 5 group by xtn_month, wom) x cross join budget_periods where x.xtn_month >= budget_periods.from_date AND x.xtn_month <= COALESCE(budget_periods.to_date::timestamp without time zone, now()::date + '5 years'::interval) and budget_periods.week = x.wom::integer"
  end

  down do
    create_or_replace_view :budget_months, "select xtn_month::date, account, amount from (select '2007-01-01'::date + (x.x || ' months')::interval as xtn_month from generate_series(0,(select 12 * extract('years' from age('2007-01-01'::date)) + extract('months' from age('2007-01-01'::date)) + 60)::integer) x ) x cross join budget_periods where xtn_month between budget_periods.from_date and (coalesce(budget_periods.to_date, now()::date + '5 years'::interval))"
  end
end
