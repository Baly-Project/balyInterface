class Country < ApplicationRecord
  has_many :regions
  has_many :cities
  has_many :locations
  has_many :previews

  validates :title, presence: true
end
