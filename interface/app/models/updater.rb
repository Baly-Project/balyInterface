class Updater
  def update(file="none") # The main update function, that is called in the rails app by "rake record:update"
    #API access sometimes fails the first time, so the iteration below allows it to try up to three times
    if file[-4..-1]=="json" #The file must be a json (.json) file
      json=IO.read(file)  
      parsed=JSON.parse(json, object_class: Slide)
      objects=parsed.results
      count=objects.length
      puts "#{count} slides read"
      #puts json,objects
      (passed,unpassed,errors)=reportErrorCheck(objects)
    else
      (objects,count)=getAllRecords()
      puts "#{count} slides read"
      (passed,unpassed,errors)=reportErrorCheck(objects)
    end
    processor=DataProcessor.new
    data=processor.processSlides(passed)
    #return data
    manager=ModelManager.new
    return manager.prepareindices(data)
  end
  def getAllRecords()
    api=ApiHandler.new
    objects=api.getRecord(parsed:true,maxtries:20)
    puts objects
    count=objects.length
    return [objects,count]
  end
  def errorCheck(slides)
    (passed,unpassed,errors)=[Array.new,Array.new,Hash.new]
    puts "CLASS=#{errors.class}"
    slides.each do |obj|
      begin
        if obj.configured_field_t_object_notation.class == NilClass
          unpassed.push obj
          id=obj.id
          errors[id]="Slide #{id} failed check because it has a blank object_notation field"
          puts errors[id]
        else
          obj.detectErrors
          passed.push obj
        end
      rescue => e
        begin
          id=obj.id
          puts "Slide #{id} did not pass error checking, due to a #{e.class} stating #{e.message}. Update the record on Digital Kenyon"
          errors[id]=e
        rescue
          title=obj.title
          puts "Slide titled '#{title}' did not pass error checking, due to a #{e.class} stating #{e.message}. Update the record on Digital Kenyon"
          errors[title]=e
        end
        unpassed.push obj
      end
    end
    return [passed,unpassed,errors]
  end
  def reportErrorCheck(slides)
    (passed,unpassed,errors)=errorCheck(slides)
    passedids=Array.new
    passed.each do |slide| passedids.push slide.id end
    puts "#{passed.length} slides passed, #{passedids}"
    return [passed,unpassed,errors]
  end
  class DataProcessor
    def processSlides(slides)
      ids=Array.new
      placetoids={:country=>{},:region=>{},:city=>{}}
      placeinfo=Hash.new
      genLocstoids=Hash.new
      genLocstocoords=Hash.new
      keywordstoids=Hash.new
      termstoids=Hash.new
      collections=Hash.new
      years=Hash.new
      timeperiods=Hash.new
      stamps=Hash.new
      slides.sort_by{|slide| slide.sortingNumber}.each do |slide|
        id=slide.sortingNumber
        ids.push id
        processPlaces(placetoids,placeinfo,genLocstoids,genLocstocoords,slide,id)
        slide.keywords.each do |word|
          keywordstoids.increment(word,id)
        end
        slide.altTerms.each do |name|
          termstoids.increment(name,id)
        end
        collection=slide.subcollection
        collections.increment(collection,id)
        years.increment(slide.year,id)
        processDate(timeperiods,slide,id)
        stamp=slide.batchStamp
        if stamp.length < 1
          stamp="unstamped"
        end
        stamps.increment(stamp,id)
      end
      return OpenStruct.new({
        :ids => ids,
        :placeIds => placetoids,
        :placeInfo => placeinfo,
        :genLocIds => genLocstoids,
        :genLocCoords => genLocstocoords,
        :keywordIds => keywordstoids,
        :termIds=>termstoids,
        :collections=>collections,
        :years => years,
        :timeperiods => timeperiods,
        :stamps => stamps
      })
    end
    def processPlaces(placetoids,placeinfo,genLocstoids,genLocstocoords,slide,id)
      crcData={:city=>uncover(slide.city),:region=>uncover(slide.region),:country=>uncover(slide.country)}
      crcData.each do |key,value|
        if value == nil
          value=makeEmptyObj(key)
        end
        placetoids[key].increment(value,id)
      end
      (country,region,city)=[crcData[:country],crcData[:region],crcData[:city]]
      placeinfo.appendCRChash(country)
      if placeinfo[country].keys.include? region
        unless placeinfo[country][region].include? city
          placeinfo[country].increment(region,city)
        end
      else
        placeinfo[country].increment(region,city)
      end
      genloc=slide.locations(general:true)
      if genloc.class==Array
        genLocstoids.increment(genloc[0],id)
        unless genLocstocoords[genloc[0]]==genloc[1]
          genLocstocoords.increment(genloc[0],genloc[1])
        end
      end
    end
    def processDate(timeperiods,slide,id)
      stringdate=slide.configured_field_t_documented_date[0]
      puts "DATE=#{stringdate}"
      begin
        date=EnhancedDate.parse(stringdate)
      rescue
        if stringdate.to_i.to_s == stringdate
          date=OpenStruct.new({:year=>stringdate.to_i})
        else
          date=""
        end
      end
      if date.class == OpenStruct
        if timeperiods.keys.include? date.year
          timeperiods[date.year.to_s].increment("nomonth",id)
        else
          timeperiods[date.year.to_s]={"nomonth"=>[id]}
        end
      else
        if timeperiods.keys.include? date.year
          # unless timeperiods[date.year].include? date.stringMonth
            timeperiods[date.year.to_s].increment(date.stringMonth,id)
          # else
          #   timeperiods[date.year][date.stringMonth] id
          # end
        else
          timeperiods[date.year.to_s]={date.stringMonth=>[id]}
        end
      end
    end
    def uncover(attribute)
      if attribute.class == Array
        return attribute[0]
      else
        return nil
      end
    end
    def makeEmptyObj(sym)
      return "no"+sym.to_s
    end
  end
  
  class ModelManager
    ModelOrder=[
    :years,
    :months,
    :stamps,
    :placeInfo,
    :genLocIds,
    :genLocCoords,
    :keywordIds,
    :termIds,
    :collections,
    :timeperiods,
    :stamps,
    :ids,
    ]
    def prepareindices(data)  
      yearindex=Hash.new
      data.years.keys.each do |yearstring|
        yearindex[yearstring]=Year.new(number:yearstring.to_i)
        yearindex[yearstring].save
      end
      monthindex=Hash.new
      data.timeperiods.each do |year, monthHash|
        yearToUse=yearindex[year]
        monthindex[year]=Hash.new
        monthHash.keys.each do |month|
          begin
            mNumber=Date.parse("#{month}, 1970").month
          rescue
            mNumber=13
          end
          monthindex[year][month]=Month.new(title:month,number:mNumber,year:yearToUse)
          monthindex[year][month].save
        end
      end
      stampindex=Hash.new
      parser=EnhancedDate.new
      data.stamps.keys.each do |stamp|
        begin
          dateHash=parser.parseStamp(stamp)
          yearToUse=yearindex[dateHash[:year]]
          monthToUse=monthindex[dateHash[:year]][dateHash[:month]]
          if monthToUse.class == Month
            stampindex[stamp]=Stamp.new(title:stamp,month:monthToUse,year:yearToUse)
          else
            stampindex[stamp]=Stamp.new(title:stamp,year:yearToUse)
          end
        rescue
          stampindex[stamp]=Stamp.new(title:stamp)
        end
        stampindex[stamp].save
      end
      return yearindex,monthindex,stampindex
    end
  end
end
