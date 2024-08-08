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
end