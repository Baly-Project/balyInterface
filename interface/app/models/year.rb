class Year < ApplicationRecord
  has_many :previews
  has_many :months

  validates :number, presence: true

  def generateSearchEntry
    link = "years/#{self.number}"
    title = self.number.to_s
    return [title,link]
  end
end
