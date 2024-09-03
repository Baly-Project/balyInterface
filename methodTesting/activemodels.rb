#A collection of the ActiveModel classes present in interface/app/models.
# class data is not included, just the names and relevant methods
# 
class ModelError < StandardError # An error class to simulate the errors produced by rails when saving models
end
class SampleModel < OpenStruct
  def save
    puts "saving"
    valuesToCheck=Array.new
    [self.checkVals,self.relVals].each do |arr|
      print arr
      if arr.to_s.length > 0
        valuesToCheck.push arr
      else 
        valuesToCheck.push []
      end
    end
    valuesToCheck[0].each do |attr|
      unless self[attr].to_s.length > 0
        raise ModelError.new "Model #{self} cannot be saved because of an empty #{attr} value"
      end
    end
    valuesToCheck[1].each do |attr,expectedClass|
      puts self[attr].class.to_s
      unless self[attr].class.to_s == expectedClass
        raise ModelError.new "Model #{self} cannot be saved because it is does not have a #{expectedClass} object as its #{attr} value"
      end
    end
    return true
  end
end

class Year < SampleModel
  def checkVals
    return [:number]
  end
  def relVals
    return []
  end
end
class Month < SampleModel
  def checkVals
    return [:title,:number]
  end
  def relVals
    return {:year=>"Year"}
  end
end
class Stamp < SampleModel
  def checkVals
    return [:title]
  end
  def relVals
    return {:month=>"Month",:year=>"Year" }
  end
end
class Collection < SampleModel
  def checkVals
    return [:title,:alph_value]
  end
  def relVals
    return []
  end
end
class Country < SampleModel
  def checkVals
    return [:title]
  end
  def relVals
    return []
  end
end
class Region < SampleModel
  def checkVals
    return [:title]
  end
  def relVals
    return {:country=>"Country"}
  end
end
class City < SampleModel
  def checkVals
    return [:title]
  end
  def relVals
    return {:country=>"Country",:region=>"Region"}
  end
end
class Keyword < SampleModel
  def checkVals
    return [:title]
  end
  def relVals
    return {}
  end
end
class Location < SampleModel
  def checkVals
    return [:title,:coordinates]
  end
  def relVals
    return {:country=>"Country",:region=>"Region",:city => "City"}
  end
end
class Preview < SampleModel
  def checkVals
    return [:title]
  end
  def relVals
    return {:collection=>"Collection",:location=>"Location",:country=>"Country",:region=>"Region",:city => "City",:stamp=>"Stamp",:month=>"Month",:year=>"Year"}
  end
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