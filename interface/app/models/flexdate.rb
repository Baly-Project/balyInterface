class Flexdate
  def initialize(array)
    if array.class==OpenStruct
      arr=arrayFromStruct(array)
    elsif array.class == Array
      arr=array[0..-1]
    else
      raise StandardError.new "The invalid object #{array} was passed into Flexdate params"
    end
    existing=Array.new
    arr.each do |item|
      unless item.include?("-") or item.length<1
        existing.push item
      end
    end	
    numentries=existing.length
    @numattrs=numentries
    if numentries == 3
      (@day,@month,@year)=existing
    elsif numentries == 2
      (@month,@year)=existing
    elsif numentries == 1
      @year=existing[0]
    else
      @numattrs=0
    end
  end

  def displayable?
    return @numattrs > 0
  end
 
  def to_s
    if @numattrs == 2
      return @month+", "+@year
    elsif @numattrs == 0
      raise StandardError.new "An empty date is being displayed"
    elsif @numattrs == 1
      return @year
    elsif @numattrs == 3
      return @month+" "+@day+", "+@year
    end
  end
  

  
  def arrayFromStruct(aStruct)
    array=Array.new
    hashform=aStruct.to_h
    [:day,:month,:year].each do |attr|
      value=hashform[attr]
      if value.class == String
        array.push value
      end 
    end
    return array
  end      
end
