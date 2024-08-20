class EnhancedTime < Time
  def getFileAddon
    cdate=self.ctime
    components=cdate.split(" ")
    finalstring=components[1]+"_"+components[2]+"_"+components[-1]
    finalstring+="_"+self.secondsSinceMidnight.to_s
    return finalstring
  end
  def secondsSinceMidnight
    (seconds,minutes,hours)=[self.sec,self.min,self.hour]
    return hours*3600+minutes*60+seconds
  end
end