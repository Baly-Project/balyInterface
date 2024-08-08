class Year < ApplicationRecord
  has_many :previews
  has_many :months

  validates :number, presence: true
end
