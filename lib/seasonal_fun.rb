module SeasonalFun
  extend self

  def season
    return :xmas if xmas?
  end

  private

  def xmas?
    [11, 12].include? Time.now.month
  end
end
