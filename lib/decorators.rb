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

    url = "/reports/register?" + params.map { |k,v| "#{k}=#{v}" }.join("&")
    link_text = cell.text.gsub('Expenses:', '').gsub('Liabilities:', '')
    cell.text = "<a href=\"#{url}\">#{link_text}</a>"
    cell
  end
end
