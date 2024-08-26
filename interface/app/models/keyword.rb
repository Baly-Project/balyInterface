class Keyword < ApplicationRecord
  has_and_belongs_to_many :previews

  def getPeriods
    a=CustomPattern.new
    return a.returnPeriodHash
  end
end
