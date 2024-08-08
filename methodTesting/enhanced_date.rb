#This is a copy of the enhanced_date.rb file from the interface app, stored in interface/app/models
class EnhancedDate < Date
  Months=["January","February","March","April","May","June","July","August","September","October","November","December"]
  def stringMonth
    return Months[self.month-1]
  end
  def parseStamp(stringin)
    input=stringin.lstrip.rstrip
    halves=input.split " "
    if halves[0].lstrip == "ENE"
      monthin="JAN"
    else
      monthin=halves[0]
    end
    yearin=halves[1][..1]
    date=Date.parse(monthin+" \'"+yearin)
    year=date.year
    if year > 2000
        year=year-100
    end
    return {month:Months[date.month-1],year:year.to_s}
  end
end