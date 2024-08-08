class Month < ApplicationRecord
  belongs_to :year
  has_many :previews
  has_many :stamps

  validates :title, presence: true
  validates :number, presence: true
end
