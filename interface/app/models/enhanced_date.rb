class EnhancedDate < Date
  Months=["January","February","March","April","May","June","July","August","September","October","November","December"]
  def stringMonth
    return Months[self.month-1]
  end
end
