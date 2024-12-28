class City < ApplicationRecord
  belongs_to :region
  belongs_to :country
  has_many :locations
  has_many :previews

  validates :title, presence: true

  def generateSearchEntry
    link = "places/cities/#{self.id}"
    title = self.title
  end
end
