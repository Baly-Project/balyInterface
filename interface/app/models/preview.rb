class Preview < ApplicationRecord
  belongs_to :collection
  belongs_to :location
  belongs_to :city
  belongs_to :region
  belongs_to :country
  belongs_to :stamp
  belongs_to :month
  belongs_to :year

  validates :title, presence:true
  validates :sorting_number, presence:true
  validates :img_link, presence:true
end
