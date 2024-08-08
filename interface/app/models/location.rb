class Location < ApplicationRecord
  belongs_to :city
  belongs_to :region
  belongs_to :country
  has_many :previews

  validates :title, presence: true
  validates :coordinates, presence: true
end
