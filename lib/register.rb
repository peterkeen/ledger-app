class RegisterReport < LedgerWeb::Report
  def self.run(opts={})
    opts.each do |key, value|
      params[key] ||= value
    end
    
    outer_where_clauses = opts.delete(:outer_where_clauses) || []

    outer_where_clauses << "xtn_year = date_trunc('year', cast(:year as date))" unless params[:year].to_s == ""
    outer_where_clauses << "xtn_month = date_trunc('month', cast(:month as date))" unless params[:month].to_s == ""
    outer_where_clauses << "xtn_week = date_trunc('week', cast(:week as date))" unless params[:week].to_s == ""

    outer_where_clause = (outer_where_clauses.empty? ? ['1 = 1'] : outer_where_clauses).join(" and ")

    inner_where_clauses = opts.delete(:inner_where_clauses) || []
    inner_where_clauses << "account ~* :account" unless params[:account].to_s == ""
    inner_where_clauses << "note ~* :payee" unless params[:payee].to_s == ""
    inner_where_clauses << "xtn_id = :xtn_id" unless params[:xtn_id].to_s == ""
    inner_where_clauses << "not virtual" if params[:include_virtual] != "on"
    inner_where_clauses << "cleared" if params[:cleared] == "on"
    inner_where_clauses << "cleared = false" if params[:uncleared] == "on"

    tags = opts[:tags_hash] || {}

    if params[:tags]
      tag_strings = params[:tags].split(/,/)
      tag_strings.each do |tag|
        tags[tag] = value
      end
    end

    tags.each do |tag, value|
      inner_where_clauses << "(jtags->>'#{tag.to_s}') = '#{value}'"
    end
    
    raise "Need either account regex or xtn_id" if inner_where_clauses.empty?

    inner_where_clause = inner_where_clauses.join(" and ")
      
    query = """
      select
          xtn_id as \"Xtn\",
          xtn_date as \"Date\",
          account as \"Account\",
          note as \"Payee\",
          amount as \"Amount\",
          cleared as \"Cleared\",
          receipt as \"Receipt\",
          sum(amount) over (order by xtn_date, xtn_id rows unbounded preceding) as \"Sum\",
          running_sum as \"Balance\"
      from (
          select
              xtn_id,
              xtn_date,
              xtn_year,
              xtn_month,
              xtn_week,
              account,
              note,
              amount,
              cleared,
              jtags->>'receipt' as receipt,
              sum(amount) over (order by xtn_date, xtn_id rows unbounded preceding) as running_sum
          from
              ledger
          where
              #{inner_where_clause}
          order by
              xtn_date desc,
              xtn_id desc
       ) x
       where
          #{outer_where_clause}
       order by xtn_date desc, xtn_id desc
    """
    from_query(query)
  end

  def self.decorate(table)
    table.hide /Cleared/

    table.decorate :all => LedgerWeb::Decorators::HighlightDecorator.new('#d9edf7'), :if => lambda{|c,r| !r[5].value }
    table.decorate /Xtn/ => LedgerWeb::Decorators::IconDecorator.new('chevron-right')
    table.decorate /Receipt/ => LedgerWeb::Decorators::IconDecorator.new('list-alt'), :if => ->(c,r) { !c.value.nil? }

    table.link /Account/ => "/reports/_register?account=:this&include_virtual=#{params[:include_virtual]}&year=#{params[:year]}&month=#{params[:month]}&cleared=#{params[:cleared]}}"
    table.link /Payee/ => "/reports/_register?account=&include_virtual=#{params[:include_virtual]}&year=#{params[:year]}&month=#{params[:month]}&cleared=#{params[:cleared]}&payee=:this"
    table.link /Xtn/ => "/reports/_register?xtn_id=:this&include_virtual=#{params[:include_virtual]}"
    table.link /Receipt/ => "/files/receipts/:this", :if => ->(c,r) { !c.value.nil? }      
  end
end
