Sequel.migration do
  up do
    create_or_replace_view :budget_months, "select xtn_month, account, amount, wom from (select xtn_month, wom::integer from calendar where dow = 5 group by xtn_month, wom) x cross join budget_periods where x.xtn_month >= budget_periods.from_date AND x.xtn_month <= COALESCE(budget_periods.to_date::timestamp without time zone, now()::date + '5 years'::interval) and (budget_periods.week = x.wom::integer or budget_periods.week is null) and (budget_periods.month = extract(month from x.xtn_month) or budget_periods.month is null)"
  end

  down do
    create_or_replace_view :budget_months, "select xtn_month, account, amount, wom from (select xtn_month, wom::integer from calendar where dow = 5 group by xtn_month, wom) x cross join budget_periods where x.xtn_month >= budget_periods.from_date AND x.xtn_month <= COALESCE(budget_periods.to_date::timestamp without time zone, now()::date + '5 years'::interval) and budget_periods.week = x.wom::integer"    
  end
end
