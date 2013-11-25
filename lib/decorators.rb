class TextColorDecorator
  def initialize(color)
    @color = color
  end
  
  def decorate(cell, row)
    cell.style[:color] = @color
    cell
  end
end

class BillLinkDecorator
  def decorate(cell, row)
    account = cell.text
    url = "/reports/register?account=#{account}&year=#{row[1].value.to_s}"
    link_text = account.gsub('Expenses:', '').gsub('Liabilities:', '')
    cell.text = "<a href=\"#{url}\">#{link_text}</a>"
    cell
  end
end
