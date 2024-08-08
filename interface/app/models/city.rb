class City < ApplicationRecord
  belongs_to :region
  belongs_to :country
  has_many :locations
  has_many :previews

  validates :title, presence: true
end
