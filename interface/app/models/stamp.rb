class Stamp < ApplicationRecord
  belongs_to :month
  belongs_to :year
  has_many :previews

  validates :title, presence:true

  def generateSearchEntry
    link = "stamps/#{self.id}"
    title = self.title
    return [title,link]
  end
end
