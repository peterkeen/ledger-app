class RegisterReport < LedgerWeb::Report
  def self.run
    where_clauses = []
    where_clauses << "xtn_year = date_trunc('year', cast(:year as date))" unless params[:year].to_s == ""
    where_clauses << "xtn_month = date_trunc('month', cast(:month as date))" unless params[:month].to_s == ""

    where_clause = (where_clauses.empty? ? ['1 = 1'] : where_clauses).join(" and ")

    from_query("""
      select
          xtn_date as \"Date\",
          account as \"Account\",
          note as \"Payee\",
          amount as \"Amount\",
          cleared as \"Cleared\",
          sum(amount) over (order by xtn_date rows unbounded preceding) as \"Sum\",
          running_sum as \"Balance\"
      from (
          select
              xtn_date,
              xtn_year,
              xtn_month,
              account,
              note,
              amount,
              cleared,
              sum(amount) over (order by xtn_date rows unbounded preceding) as running_sum
          from
              ledger
          where
              account ~* :account
              and (case when :cleared then cleared else true end)
              and (case when :include_virtual then true else not virtual end)
          order by
              xtn_date desc
       ) x
       where
          #{where_clause}
    """)
  end
end
