class Updater
  def update(file:"none",log:PrintLogger.new) # The main update function, that is called in the rails app by "rake record:update"
    @log=log
    if file[-4..-1]=="json" #The file must be a json (.json) file
      json=IO.read(file)  
      parsed=JSON.parse(json, object_class: Slide)
      objects=parsed.results
      count=objects.length
    else
      (objects,count)=getAllRecords()
    end
    @log.puts "#{count} slides read"
    #@log.puts json,objects
    (passed,unpassed,errors)=reportErrorCheck(objects)
    processor=DataProcessor.new(@log)
    data=processor.processSlides(passed)
    analyzer=PatternAnalyzer.new
    synthpatterns=analyzer.gatherLocationPatterns(data)
    inputreader=CustomPattern.new
    patterns=synthpatterns.merge inputreader.returnAll
    manager=ModelManager.new(@log)
    index = manager.prepareindices(data,patterns)
    index[:ids] = manager.preparePrevIndex(passed)
    if index[:ids].keys.sort != data.ids
      @log.puts "WARNING: IDs read on input do not match the models"
      return index[:ids].keys.sort, data.ids
    end
    data = manager.assignPreviewData(index,data)
    return data    
  end
  
  private
	
  def getAllRecords()
    api=ApiHandler.new
    objects=api.getRecord(parsed:true,fields:"all",maxtries:20,check:[:configured_field_t_object_notation,:download_link])
    count=objects.length
    return [objects,count]
  end
  def errorCheck(slides)
    (passed,unpassed,errors)=[Array.new,Array.new,Hash.new]
    slides.each do |obj|
      begin
        if obj.configured_field_t_object_notation.class == NilClass
          unpassed.push obj
          id=obj.id
          errors[id]="Slide #{id} failed check because it has a blank object_notation field"
          @log.puts errors[id]
        else
          obj.detectErrors
          passed.push obj
        end
      rescue => e
        begin
          id=obj.id
          @log.puts "Slide #{id} did not pass error checking, due to a #{e.class} stating #{e.message}. Update the record on Digital Kenyon"
          errors[id]=e
        rescue
          title=obj.title
          @log.puts "Slide titled '#{title}' did not pass error checking, due to a #{e.class} stating #{e.message}. Update the record on Digital Kenyon"
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
    @log.puts "#{passed.length} slides passed, #{passedids}"
    return [passed,unpassed,errors]
  end
  class DataProcessor #This subclass collects the attributes from the passed slides
    def initialize(logger=PrintLogger.new)
      @log=logger
    end
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
      orientations=Hash.new
      @log.print "\nProcessing Slides"
      slides.sort_by{|slide| slide.sortingNumber}.each do |slide|
        begin 
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
            stamp= "unstamped"
          end
          stamps.increment(stamp,id)
          orientations[id]=getImgDims(slide.download_link)
          @log.print "."
        rescue => e
          @log.puts "An error occurred with slide #{slide.sortingNumber}"
          raise e
        end
      end
      #@log.print "\n"+timeperiods.to_s+"\n"
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
        :stamps => stamps,
        :orientations => orientations
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
	if genloc[0].length < 3
          genLocstoids.increment("No Location",id)
        else
          genLocstoids.increment(genloc[0],id)
        end
        unless genLocstocoords[genloc[0]]==genloc[1]
          genLocstocoords[genloc[0]]=genloc[1]
        end
      end
    end
    def processDate(timeperiods,slide,id)
      begin
      	stringdate = slide.configured_field_t_documented_date[0]
      rescue 
	      @log.puts "Slide with sorting number #{id} does not have a documented date. If this is a mistake, fix the record on Digital Kenyon"
	      begin 
          stringdate = EnhancedDate.parse(slide.publication_date).year.to_s
	      rescue
          stringdate  = "3000"
        end
      end
      #@log.puts "DATE=#{stringdate}"
      begin
        date = EnhancedDate.parse(stringdate)
      rescue
        if stringdate.to_i.to_s == stringdate
          date = OpenStruct.new({:year => stringdate.to_i})
        else
          date = OpenStruct.new({:year => 3000})
          @log.puts "Slide with sorting number #{id} with documented date #{stringdate} could not be parsed, and has been treated as undated"
        end
      end
      if date.class == OpenStruct
        if timeperiods.keys.include? date.year.to_s
          timeperiods[date.year.to_s].increment("nomonth",id)
        else
          timeperiods[date.year.to_s] = {"nomonth"=>[id]}
        end
      else
        if timeperiods.keys.include? date.year.to_s
          # unless timeperiods[date.year].include? date.stringMonth
          timeperiods[date.year.to_s].increment(date.stringMonth,id)
          # else
          #   timeperiods[date.year][date.stringMonth] id
          # end
        else
          timeperiods[date.year.to_s] = {date.stringMonth=>[id]}
        end
      end
    end
    def getImgDims(link)
      dims = FastImage.size(link)
      if dims.to_s.length < 1
        @log.print "Link #{link} returned null size from FastImage"
        tries = 0
        while dims.to_s.length < 1 and tries < 5
          dims = FastImage.size(link)
          tries += 1
        end
      end
      ratio=dims[0].to_f/dims[1].to_f
      if ratio > 1.2
        return "L"
      elsif ratio < 0.83
        return "P"
      else
        return "S"
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
  class PatternAnalyzer #this subclass uses the Set class extensively to find suspected super/subsets among the idlists.
    def checkAllPatterns(data)
      locationPlaces=locationsToPlaces(data[:locations],data[:placeIds])
      keywordsubsets=keywordSubsets(data[:keywords])
      keywordTerms=keywordsToTerms(data[:keywords],data[:termIds])
      return {
        locations:locationPlaces,
        keywords:keywordsubsets,
        terms:keywordTerms
      }
    end
    def gatherLocationPatterns(data)
      locationPlaces=locationsToPlaces(data[:locations],data[:placeIds])
      return {locationPlaces:locationPlaces}
    end
    def locationsToPlaces(locdata,placedata)
      locsToPlaces={countries:Hash.new,regions:Hash.new,cities:Hash.new}
      locdata.each do |locname, locidlist|
        placedata.each do |sym,placeIdHash|
          placeIdHash.each do |placename, placeidlist|
            if Set.new(locidlist).subset? Set.new(placeidlist)
              locsToPlaces[sym][locname]=placename
            end
          end
        end
      end
      return locsToPlaces
    end
    def keywordSubsets(keyworddata)
      keywordsubsetsall=Hash.new
      keywordsubsets=Hash.new
      keyworddata.each do |word1,idList1|
        keyworddata.each do |word2,idList2|
          if word1 != word2
            if Set.new(idList1).subset?(Set.new(idList2)) and idList1.length < idList2.length
              if keywordsubsetsall.keys.include? word1
                keywordsubsetsall[word1].push word2
              else
                keywordsubsetsall[word1]=[word2]
              end
            end
          end
        end
        if keywordsubsetsall.keys.include? word1
          keywordsubsets[word1]=keywordsubsetsall[word1].sort_by{|superword| keyworddata[superword].length}[0]
        end
      end
      return keywordsubsets
    end
    def keywordsToTerms(keyworddata,termdata)
      keywordTerms=Hash.new
      finalkeywordTerms=Hash.new
      keyworddata.each do |word,idList1|
        termdata.each do |term,idList2|
          if idList1.sort == idList2.sort
            if keywordTerms.keys.include? word
              keywordTerms[word].push term
            else
              keywordTerms[word]=[term]
            end
          end
        end
      end
      keywordTerms.each do |word,termlist|
        terms=String.new
        termlist.each do |term|
          terms+=term+", "
        end
        finalterms=terms[0...-2]
        finalkeywordTerms[word]=finalterms
      end
      return finalkeywordTerms
    end
  end
  class ModelManager # This subclass creates models for each attribute, finally assigning them to the various preview objects
    def initialize(logger=PrintLogger.new)
      @log=logger
    end
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
    def prepareindices(data,patterns)
      deleter=SafeDeleter.new
      deleter.clearDatabase
      emptyYear=Year.new(id:1,number:3000)
      emptyYear.save
      emptyMonth=Month.new(id:1,title:"No Month",number:13,year:emptyYear)
      emptyMonth.save
      (yearindex,monthindex)=processTimes(data,emptyMonth,emptyYear)
      stampindex=processStamps(data.stamps,yearindex,monthindex,emptyMonth,emptyYear)
      #return yearindex,monthindex,stampindex
      (countryindex,regionindex,cityindex, emptyCountry,emptyRegion,emptyCity)=processPlaces(data.placeInfo)
      emptyLocation=Location.new(id:1,title:"No Location", coordinates:"do not display",city:emptyCity,region:emptyRegion,country:emptyCountry)
      emptyLocation.save
      locationindex={"No Location"=>emptyLocation}
      thislocation=2
      keywordindex=processKeywords(data.keywordIds,patterns)
      locPatterns=patterns[:locationPlaces]
      terms=patterns[:keywordTerms]
      data.locationCoords.each do |title,coords|
        if title.length > 1
          if locPatterns[:countries][title].class == String
            country=countryindex[locPatterns[:countries][title]]
          else
            country=emptyCountry
          end
          if locPatterns[:regions][title].class == String
            region=regionindex[country.title][locPatterns[:regions][title]]
          else
            region=regionindex[country.title]["No Region"]
          end
          if locPatterns[:cities][title].class == String
            city=cityindex[country.title][region.title][locPatterns[:cities][title]]
          else
            city=cityindex[country.title][region.title]["No City"]
          end
          location=Location.new(id:thislocation,title:title,coordinates:coords,city:city,region:region,country:country)
          thislocation+=1
          if terms[title].class == String
            location[:alternates]=terms[title]
          end
          location.save
          locationindex[title]=location
        end
      end

      collectionsindex=Hash.new
      thiscollection=1
      data.collections.keys.each do |title|
        if title.include? ":"
          alph=title.split(":")[0].fullstrip
        elsif title.include? "-"
          alph=title.split("-")[0].fullstrip
        else
          @log.puts "Collection #{title} does not include a ':' or '-'. Update the record on digital kenyon."
        end
        unless alph.to_s.is_alphanumeric?
          raise StandardError.new "Collection #{title} does not begin with an alphanumeric"
        else
          value=alph.alphValue
        end
        collection=Collection.new(id:thiscollection,title:title,alph_value:value)
        thiscollection+=1
        collection.save
        collectionsindex[title]=collection
      end
      return {
        years:yearindex,months:monthindex,stamps:stampindex,countries:countryindex,regions:regionindex,
        cities:cityindex,keywords:keywordindex,locations:locationindex,collections:collectionsindex}
    end
    def processTimes(data,emptyMonth,emptyYear)
      yearindex={"No Year"=>emptyYear}
      thisyear=2
      data.years.keys.each do |yearstring|
        yearindex[yearstring]=Year.new(id:thisyear,number:yearstring.to_i)
        yearindex[yearstring].save
        thisyear+=1
      end
      monthindex={"No Year"=>{"No Month"=>emptyMonth}}
      thismonth=2
      data.timeperiods.each do |year, monthHash|
        yearToUse=yearindex[year]
        monthindex[year]=Hash.new
        monthHash.keys.each do |month|
          begin
            mNumber=Date.parse("#{month}, 1970").month
          rescue
            mNumber=13
          end
          monthindex[year][month]=Month.new(id:thismonth,title:month,number:mNumber,year:yearToUse)
          monthindex[year][month].save
          thismonth+=1
        end
      end
      return [yearindex,monthindex]
    end
    def processStamps(stampdata,yearindex,monthindex,emptyMonth,emptyYear)
      stampindex=Hash.new
      parser=EnhancedDate.new
      thisstamp=1
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
          stampindex[stamp]=Stamp.new(id:thisstamp,title:stamp,month:monthToUse,year:yearToUse)
          thisstamp+=1
        end
        stampindex[stamp].save
      end
      return stampindex
    end
    def processPlaces(placedata)
      emptyCountry=Country.new(id:1,title:"No Country")
      emptyCountry.save
      emptyRegion=Region.new(id:1,title:"No Region",country:emptyCountry)
      emptyRegion.save
      emptyCity=City.new(id:1,title:"No City", region:emptyRegion, country:emptyCountry)
      emptyCity.save
      countryindex={"No Country" => emptyCountry}
      regionindex={"No Country" => {"No Region"=>emptyRegion}}
      cityindex={"No Country" => {"No Region"=>{"No City" => emptyCity}}}
      thiscountry=2
      thisregion=2
      thiscity=2
      placedata.each do |countrystring, regionHash|
        country=Country.new(id:thiscountry,title:countrystring)
        thiscountry+=1
        country.save
        countryindex[countrystring] = country
        emptyRegion2=Region.new(id:thisregion,title:"No Region",country:country)
        thisregion+=1
        emptyRegion2.save
        regionindex[countrystring] = {"No Region"=>emptyRegion2}
        emptyCity2=City.new(id:thiscity,title:"No City",region:emptyRegion2,country:country)
        thiscity+=1
        emptyCity2.save
        cityindex[countrystring] = {"No Region"=>{"No City" => emptyCity2}}
        regionHash.each do |regionstring,cityList|
          region=Region.new(id:thisregion,title:regionstring,country:country)
          thisregion+=1
          region.save
          regionindex[countrystring][regionstring]=region
          emptyCity3=City.new(id:thiscity,title:"No City",region:region,country:country)
          thiscity+=1
          emptyCity3.save
          cityindex[countrystring][regionstring]={"No City" => emptyCity3}
          cityList.each do |citystring|
            city=City.new(id:thiscity,title:citystring,region:region,country:country)
            thiscity+=1
            city.save
            cityindex[countrystring][regionstring][citystring]=city
          end
        end
      end
      return [countryindex,regionindex,cityindex,emptyCountry,emptyRegion,emptyCity]
    end
    def processKeywords(keyworddata,patterns)
      subsets=patterns[:keywordSubsets]
      terms=patterns[:keywordTerms]
      keywordindex=Hash.new
      currentid=1
      keyworddata.keys.each do |word|
        newword=Keyword.new(id:currentid,title:word)
        if subsets[word].class == String
          largerword=subsets[word]
          newword[:super]=largerword
        end
        if terms[word].class == String
          altTerms=terms[word]
          newword[:alternates]=altTerms
        end
        currentid+=1
        newword.save
        keywordindex[word]=newword
      end
      return keywordindex
    end
    def preparePrevIndex(passed)
      idindex=Hash.new
      thispreview=1
      passed.sort_by{|slide| slide.sortingNumber}.each do |slide|
        title=slide.title
        sortNum=slide.sortingNumber
        descpreview=slide.makePreview(char_limit:50)
        coordinates=slide.locations(specificCoords:true)
        img_link=slide.medimg
        prev=Preview.new(id:thispreview,title:title,sorting_number:sortNum,description:descpreview,
                         coordinates:coordinates,img_link:img_link)
        thispreview+=1
        idindex[sortNum]=prev
      end
      @log.puts " "
      return idindex.sort.to_h
    end
    def assignPreviewData(index,data)
      data.years.each do |stringyear,idList|
        yearToUse=index[:years][stringyear]
        assignToIdList(index[:ids],idList,:year,yearToUse)
        begin
          data.timeperiods[stringyear].each do |monthstring,idList2|
            monthToUse=index[:months][stringyear][monthstring]
            assignToIdList(index[:ids],idList2,:month,monthToUse)
          end
        rescue
          @log.puts "year #{stringyear} was not found in the timeperiods hash"
        end
      end
      data.stamps.each do |stamp,idList|
        stampToUse=index[:stamps][stamp]
        assignToIdList(index[:ids],idList,:stamp,stampToUse)
      end
      placeIds=data.placeIds
      assignPlaces(placeIds,index)
      keywordindex=index[:keywords]
      idindex=index[:ids]
      data.keywordIds.each do |word,idList|
        keywordToUse=keywordindex[word]
        idList.each do |id|
          currentPreview=idindex[id]
          currentPreview.keywords << keywordToUse
        end
      end
      [[:collections,:collection],[:locations,:location]].each do |plsym,sym|
        data[plsym].each do |name,idList|
          begin
            modelToUse=index[plsym][name]
          rescue
            if sym == :location
              modelToUse=index[plsym]["No Location"]
            else
              @log.puts "Subcollection #{name} is missing from the collections index"
            end
          end
          assignToIdList(index[:ids],idList,sym,modelToUse)
        end
      end
      puts data.orientations
      data.orientations.each do |number,orientation|
	index[:ids][number].orientation=orientation
      end
      index[:ids].each do |key,value| 
        begin
          value.save! 
        rescue => e
          @log.puts "Preview number #{key} failed to save due to a #{e.class} stating #{e.message}"
        end
      end
      writeAutofillObject()
      return index[:ids]
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
    def writeAutofillObject()
      entries = Hash.new
      SafeDeleter.allModels.each do |model|
        if model.method_defined? :generateSearchEntry
          model.all.each do |item|
            (title,link) = item.generateSearchEntry
            if !title.include? "No "
              if entries.include? title
                entries[title].push link
              else
                entries[title] = [link]
              end
            end
          end
        end
      end        
      filetouse = Rails.root.join("public","searchdata.js")
      File.delete(filetouse) if File.exist? filetouse
      outfile = File.new(filetouse, 'w')
      outfile.print "var searchdata = "
      outfile.print JSON.pretty_generate(entries)
      outfile.close
    end
  end
end
