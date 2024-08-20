#This file is a copy of the like-named one in interface/config/initializers
class Class
  def getSymbol
    return self.to_s.downcase.to_sym
  end
end