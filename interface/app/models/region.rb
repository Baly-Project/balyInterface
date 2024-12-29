class Region < ApplicationRecord
  belongs_to :country
  has_many :cities
  has_many :locations
  has_many :previews

  validates :title, presence:true

  def generateSearchEntry
    link = "/places/regions/#{self.id}"
    title = "#{self.title}, #{self.country.title}"
    return [title,link]
  end
end
