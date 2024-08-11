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

  def set(attr,value)
    if attr == :collection
      self.collection = value
    elsif attr == :location
      self.location = value
    elsif attr == :city
      self.city = value
    elsif attr == :region
      self.region = value
    elsif attr == :country
      self.country = value
    elsif attr == :stamp
      self.stamp = value
    elsif attr == :month
      self.month = value
    elsif attr == :year
      self.year = value
    end
  end
end
