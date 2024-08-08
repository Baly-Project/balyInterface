class Stamp < ApplicationRecord
  belongs_to :month
  belongs_to :year
  has_many :previews

  validates :title, presence:true
end
