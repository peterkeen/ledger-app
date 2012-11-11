class BudgetSummaryReport < LedgerWeb::Report
  def self.run(limit=nil)
    limit_sql = limit ? "limit #{limit.to_i}" : ""
    from_query("""
      with budget_summary as (
      select
          b.xtn_month,
          x.account as account,
          x.amount as expense,
          b.amount as budgeted
      from
      budget_months b
      left outer join (
          select
              xtn_month,
              account,
              sum(amount) as amount
          from
              expenses
          where
              account in (select distinct account from budget_periods)
          group by
              xtn_month,
              account
      ) x on x.account = b.account and x.xtn_month = b.xtn_month
      order by
         b.xtn_month,
         x.account
      )
      select
          xtn_month as \"Month\",
          sum(budgeted) as \"Budget\",
          sum(expense) as \"Spent\",
          sum(budgeted) - sum(expense) as \"Diff\"
      from
          budget_summary
      group by
          xtn_month
      order by
          xtn_month desc
      #{limit_sql}
    """)
  end
end
