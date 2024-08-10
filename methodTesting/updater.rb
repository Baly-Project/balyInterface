require_relative 'api_handler.rb'
require_relative 'hash.rb'
require_relative 'enhanced_date.rb'
require_relative 'activemodels.rb'
#This is a copy of the updater.rb file from the interface app, stored in interface/app/models
class Updater
  def update(file="none") # The main update function, that is called in the rails app by "rake record:update"
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
    index = manager.prepareindices(data)
    index[:ids] = manager.preparePrevIndex(passed)
    if index[:ids].keys.sort != data.ids
      puts "WARNING: IDs read on input do not match the models"
      return index[:ids].keys.sort, data.ids
    end
    manager.assignPreviewData(index,data)
    
  end
  def getAllRecords()
    api=ApiHandler.new
    objects=api.getRecord(parsed:true,fields:"all",maxtries:20,check:[:configured_field_t_object_notation])
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
  class DataProcessor #This subclass collects the attributes from the passed slides
    def processSlides(slides)
      ids=Array.new
      placetoids={:countries=>{},:regions=>{},:cities=>{}}
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
        :locations => genLocstoids,
        :locationCoords => genLocstocoords,
        :keywordIds => keywordstoids,
        :termIds=>termstoids,
        :collections=>collections,
        :years => years,
        :timeperiods => timeperiods,
        :stamps => stamps
      })
    end
    def processPlaces(placetoids,placeinfo,genLocstoids,genLocstocoords,slide,id)
      crcData={:cities=>uncover(slide.city),:regions=>uncover(slide.region),:countries=>uncover(slide.country)}
      crcData.each do |key,value|
        if value == nil
          value=makeEmptyObj(key)
        end
        placetoids[key].increment(value,id)
      end
      (country,region,city)=[crcData[:countries],crcData[:regions],crcData[:cities]]
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
          genLocstocoords[genloc[0]]=genloc[1]
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
        if timeperiods.keys.include? date.year.to_s
          timeperiods[date.year.to_s].increment("nomonth",id)
        else
          timeperiods[date.year.to_s]={"nomonth"=>[id]}
        end
      else
        if timeperiods.keys.include? date.year.to_s
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
  class PatternAnalyzer
    def checkPatterns(data)
      #need to add array methods for subset/superset, 
      #and then run pairs of id arrays we suspect to have patterns between.
      #Each time we find a sub/superset, we log it in a attributeSubsets array
    end
  end
  class ModelManager # This subclass creates models for each attribute, finally assigning them to the various preview objects
    ModelOrder=[
    :years,
    :months,
    :stamps,
    :placeInfo,
    :locations,
    :locationCoords,
    :keywordIds,
    :termIds,
    :collections,
    :timeperiods,
    :stamps,
    :ids,
    ]
    def prepareindices(data)
      emptyYear=Year.new(number:3000)
      emptyYear.save
      emptyMonth=Month.new(title:"No Month",number:13,year:emptyYear)
      emptyMonth.save
      (yearindex,monthindex)=processTimes(data,emptyMonth,emptyYear)
      stampindex=processStamps(data.stamps,yearindex,monthindex,emptyMonth,emptyYear)
      #return yearindex,monthindex,stampindex
      (countryindex,regionindex,cityindex)=processPlaces(data.placeInfo)
      emptyLocation=Location.new(title:"No Location", coordinates:"do not display")
      emptyLocation.save
      locationindex={"No Location"=>emptyLocation}
      data.locationCoords.each do |title,coords|
        if title.length > 1
          location=Location.new(title:title,coordinates:coords)
          location.save
          locationindex[title]=location
        end
      end
      collectionsindex=Hash.new
      data.collections.keys.each do |title|
        if title.include? ":"
          alph=title.split(":")[0].fullstrip
        elsif title.include? "-"
          alph=title.split("-")[0].fullstrip
        else
          puts "Collection #{title} does not include a ':' or '-'. Update the record on digital kenyon."
        end
        unless alph.to_s.is_alphanumeric?
          raise StandardError.new "Collection #{title} does not begin with an alphanumeric"
        else
          value=alph.alphValue
        end
        collection=Collection.new(title:title,alph_value:value)
        collection.save
        collectionsindex[title]=collection
      end
      return {years:yearindex,months:monthindex,stamps:stampindex,countries:countryindex,
              regions:regionindex,cities:cityindex,locations:locationindex,collections:collectionsindex}
    end
    def processTimes(data,emptyMonth,emptyYear)
      yearindex={"No Year"=>emptyYear}
      data.years.keys.each do |yearstring|
        yearindex[yearstring]=Year.new(number:yearstring.to_i)
        yearindex[yearstring].save
      end
      monthindex={"No Year"=>{"No Month"=>emptyMonth}}
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
      return [yearindex,monthindex]
    end
    def processStamps(stampdata,yearindex,monthindex,emptyMonth,emptyYear)
      stampindex=Hash.new
      parser=EnhancedDate.new
      stampdata.keys.each do |stamp|
        begin
          dateHash=parser.parseStamp(stamp)
          yearToUse=yearindex[dateHash[:year]]
          unless yearToUse.class==Year
            yearToUse=emptyYear
          end
          monthToUse=monthindex[dateHash[:year]][dateHash[:month]]
          unless monthToUse.class == Month
            monthToUse=emptyMonth
          end
        rescue
          (yearToUse,monthToUse)=[emptyYear,emptyMonth]
        ensure
          stampindex[stamp]=Stamp.new(title:stamp,month:monthToUse,year:yearToUse)
        end
        stampindex[stamp].save
      end
      return stampindex
    end
    def processPlaces(placedata)
      emptyCountry=Country.new(title:"No Country")
      emptyCountry.save
      emptyRegion=Region.new(title:"No Region",country:emptyCountry)
      emptyRegion.save
      emptyCity=City.new(title:"No City", region:emptyRegion, country:emptyCountry)
      emptyCity.save
      countryindex={"No Country" => emptyCountry}
      regionindex={"No Country" => {"No Region"=>emptyRegion}}
      cityindex={"No Country" => {"No Region"=>{"No City" => emptyCity}}}
      placedata.each do |countrystring, regionHash|
        country=Country.new(title:countrystring)
        country.save
        countryindex[countrystring] = country
        emptyRegion2=Region.new(title:"No Region",country:country)
        emptyRegion2.save
        regionindex[countrystring] = {"No Region"=>emptyRegion2}
        emptyCity2=City.new(title:"No City",region:emptyRegion2,country:country)
        emptyCity2.save
        cityindex[countrystring] = {"No Region"=>{"No City" => emptyCity2}}
        regionHash.each do |regionstring,cityList|
          region=Region.new(title:regionstring,country:country)
          region.save
          regionindex[countrystring][regionstring]=region
          emptyCity3=City.new(title:"No City",region:region,country:country)
          emptyCity3.save
          cityindex[countrystring][regionstring]={"No City" => emptyCity3}
          cityList.each do |citystring|
            city=City.new(title:citystring,region:region,country:country)
            city.save
            cityindex[countrystring][regionstring][citystring]=city
          end
        end
      end
      return countryindex,regionindex,cityindex
    end
    def preparePrevIndex(passed)
      idindex=Hash.new
      passed.each do |slide|
        title=slide.title
        sortNum=slide.sortingNumber
        descpreview=slide.makePreview(char_limit:50)
        coordinates=slide.locations(specificCoords:true)
        img_link=slide.medimg
        prev=Preview.new(title:title,sorting_number:sortNum,description:descpreview,
                         coordinates:coordinates,img_link:img_link)
        idindex[sortNum]=prev
      end
      return idindex.sort.to_h
    end
    
    def assignPreviewData(index,data)
      data.years.each do |stringyear,idList|
        yearToUse=index[:years][stringyear]
        assignToIdList(index[:ids],idList,:year,yearToUse)
        begin
          data.timeperiods[stringyear].each do |monthstring,idList2|
            monthToUse=index[:months][stringyear][monthstring]
            assignToIdList(index[:ids],idList,:month,monthToUse)
          end
        rescue
          puts "year #{stringyear} was not found in the timeperiods hash"
        end
      end
      data.stamps.each do |stamp,idList|
        stampToUse=index[:stamps][stamp]
        assignToIdList(index[:ids],idList,:stamp,stampToUse)
      end
      placeIds=data.placeIds
      assignPlaces(placeIds,index)
      [[:collections,:collection],[:locations,:location]].each do |plsym,sym|
        data[plsym].each do |name,idList|
          begin
            modelToUse=index[plsym][name]
          rescue
            if sym == :location
              modelToUse=index[plsym]["No Location"]
            else
              puts "Subcollection #{name} is missing from the collections index"
            end
          end
          assignToIdList(index[:ids],idList,sym,modelToUse)
        end
      end
      index[:ids].each do |key,value| value.save end
    end

    def assignPlaces(placeIds,index)
      countryindex=index[:countries]
      placeIds[:countries].each do |name,idList|
        placeToUse=countryindex[name]
        assignToIdList(index[:ids],idList,:country,placeToUse)
      end
      regionindex=index[:regions]
      regionindex.each do |country,regionHash|
        regionHash.each do |name,region|
          if placeIds[:regions].keys.include? name
            idList=placeIds[:regions][name].intersection(placeIds[:countries][country])
            assignToIdList(index[:ids],idList,:region,region)
          end
        end
      end
      cityindex=index[:cities]
      cityindex.each do |country,regionHash|
        regionHash.each do |region, cityHash|
          cityHash.each do |name, city|
            if placeIds[:cities].keys.include? name
              idList=placeIds[:cities][name].intersection(placeIds[:regions][region]).intersection(placeIds[:countries][country])
              assignToIdList(index[:ids],idList,:city,city)
            end
          end
        end
      end
    end
    def assignToIdList(idindex,list,attr,value)
      list.each do |id|
        idindex[id].set(attr,value)
      end
    end
  end
end