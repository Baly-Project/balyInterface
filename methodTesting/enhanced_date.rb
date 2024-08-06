#This is a copy of the enhanced_date.rb file from the interface app.
class EnhancedDate < Date
  Months=["January","February","March","April","May","June","July","August","September","October","November","December"]
  def stringMonth
    return Months[self.month-1]
  end
end