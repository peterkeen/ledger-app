class StyleDecorator
  def initialize(styles)
    @styles = styles
  end

  def decorate(cell, row)
    @styles.each do |key, val|
      cell.style[key] = val
    end
    cell
  end
end

class ExpensesDecorator
  def initialize(additional_params={})
    @additional_params = additional_params
  end

  def decorate(cell, row)
    return cell if cell.text == "Total"

    params = {
      account: cell.text
    }

    @additional_params.each do |k,v|
      params[k] = v.is_a?(Proc) ? v.call(cell, row) : v
    end

    url = "/reports/_register?" + params.map { |k,v| "#{k}=#{v}" }.join("&")
    link_text = cell.text.gsub('Expenses:', '').gsub('Liabilities:', '')
    cell.text = "<a href=\"#{url}\">#{link_text}</a>"
    cell
  end
end

class BankAccountDecorator
  URLS = [
    [ /Assets:Schwab/,              'https://www.schwab.com' ], 
    [ /Assets:BofA/,                'https://www.bankofamerican.com' ], 
    [ /Assets:Amex/,                'https://personalsavings.americanexpress.com' ],
    [ /Liabilities:Chase/,          'https://www.chase.com' ],
    [ /Liabilities:Loans:Mortgage/, 'https://www.wellsfargo.com' ]
  ]

  def decorate(cell, row)
    return cell if row[0].text == "Total"
    url = URLS.detect { |u| u[0].match(row[0].value) }
    cell.text = "<a target=\"_blank\" href=\"#{url[1]}\"><i class=\"icon-share-alt\"></i></a>"
    cell
  end
end
