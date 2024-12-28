class Country < ApplicationRecord
  has_many :regions
  has_many :cities
  has_many :locations
  has_many :previews

  validates :title, presence: true

  def generateSearchEntry
    link = "places/countries/#{self.id}"
    title = self.title
    return [title,link]
  end
end
