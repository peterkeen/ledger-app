class BudgetSummaryReport < LedgerWeb::Report
  def self.run(limit=nil)
    limit_sql = limit ? "limit #{limit.to_i}" : ""
    month_where = params[:month] ? 'xtn_month = :month' : '1 = 1'
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
              and tags !~ 'Reimburseable'
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
          coalesce(sum(expense), 0) as \"Spent\",
          sum(budgeted) - coalesce(sum(expense), 0) as \"Diff\"
      from
          budget_summary
      where
          #{month_where}
      group by
          xtn_month
      order by
          xtn_month desc
      #{limit_sql}
    """)
  end
end
