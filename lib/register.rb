class RegisterReport < LedgerWeb::Report
  def self.run
    where_clauses = []
    where_clauses << "xtn_year = date_trunc('year', cast(:year as date))" if params[:year]
    where_clauses << "xtn_month = date_trunc('month', cast(:month as date))" if params[:month]

    where_clause = (where_clauses.empty? ? ['1 = 1'] : where_clauses).join(" and ")

    from_query("""
      select
          xtn_date as \"Date\",
          account as \"Account\",
          note as \"Payee\",
          amount as \"Amount\",
          cleared as \"Cleared\",
          running_sum as \"Sum\"
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
              account = :account
              and (case when :cleared then cleared else true end)
              and (case when :include_virtual then true else not virtual end)
          order by
              xtn_date
       ) x
       where
          #{where_clause}
    """)
  end
end
