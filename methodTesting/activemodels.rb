#A collection of the ActiveModel classes present in interface/app/models.
# class data is not included, just the names and relevant methods
# 
class SampleModel < OpenStruct
  def save
    return true    
  end
end

class Year < SampleModel
end
class Month < SampleModel
end
class Stamp < SampleModel
end
class Collection < SampleModel
end
class Country < SampleModel
end
class Region < SampleModel
end
class City < SampleModel
end
class Location < SampleModel
end
class Preview < SampleModel
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