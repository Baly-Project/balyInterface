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

  def makePlaceLinks
    plurals=["cities","regions","countries"]
    (city,region,country)=[self.city,self.region,self.country]
    placeLinks=Hash.new
    counter=0
    [city,region,country].each do |place|
      link="/places/"+plurals[counter]+"/"+place.id.to_s
      placeLinks[place.title]=link
      counter+=1
    end
    return placeLinks
  end
  Alphabet=("A".."Z").to_a
  def classification
    sortnumber=self.sorting_number
    firstLetter=sortnumber/26000
    secondLetter=(sortnumber/1000)%26
    number=sortnumber%1000
    first=Alphabet[firstLetter-1]
    second=Alphabet[secondLetter-1]
    return first+second+"."+number.to_s
  end
  def fullImgLink
    number=self.img_link.split("/")[-2]
    unless number.is_integer? == false
      return "https://digital.kenyon.edu/context/baly/article/#{number}/type/native/viewcontent"
    else 
      raise StandardError.new "Image link for slide #{self.title} is invalid, and other links could not be generated"
    end    
  end
end
