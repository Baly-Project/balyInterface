#This is a copy of the hash.rb file from the interface app, stored in interface/config/initializers
class Hash
  def increment(key,val)
    if self.keys.include? key
      self[key].push val
    elsif val.to_s.length > 0
      self[key]=[val]
    end
  end
  def incrementUnlessEmpty(key,val,lengthlimit=2)
    if val.to_s.length > lengthlimit
      increment(key,val)
    end
  end
  def appendCRChash(place)
    unless self.keys.include? place
      self[place]=Hash.new
    end
  end
end