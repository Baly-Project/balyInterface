class Region < ApplicationRecord
  belongs_to :country
  has_many :cities
  has_many :locations
  has_many :previews

  validates :title, presence:true
end
