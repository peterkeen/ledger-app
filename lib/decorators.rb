class TextColorDecorator
  def initialize(color)
    @color = color
  end
  
  def decorate(cell, row)
    cell.style[:color] = @color
    cell
  end
end
