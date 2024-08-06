class Slide < OpenStruct

  #Accessor Methods ####################
  def cleanTitle
    cleantitle=""
    brokentitle=self.title.split " "
    if brokentitle[0][-1].to_i.to_s == brokentitle[0][-1]
      brokentitle[1..].each do |frag|
        cleantitle+=frag+" "
      end
    end
    return cleantitle.rstrip
  end

  def cleanAbstract
    return cleantext(self.abstract)
  end

  def cleanImageNotes
    return cleantext(self.configured_field_t_image_notes[0])
  end

  def cleanCuratorNotes
    return cleantext(self.configured_field_t_curator_notes[0])
  end

  def cleanDescription
    return cleantext(self.configured_field_t_description[0])
  end
  def medimg
    begin
      medlink=self.getImgLinks(self.download_link)[0]
    rescue
      medlink="UNFOUND"
    ensure
      return medlink
    end
  end

  def thumbnail
    begin
      thmlink=self.getImgLinks(self.download_link)[1]
    rescue
      medlink="UNFOUND"
    ensure
      return thmlink
    end
  end

  def pagelink
    return self.url
  end

  def year
    return prepYear
  end
  def sortingNumber
    return self.configured_field_t_sorting_number[0].to_i
  end
  def dates
    datesHash=Hash.new
    metadata=self.meta
    dateinfo=metadata.dates
    dateinfo.each do |date|
      if date.year.to_s.length > 3
        datesHash[date.type.capitalize+" Date"]=Flexdate.new(date)
      end
    end
    return datesHash
  end

  def notes
    notesHash=Hash.new
    metadata=self.meta
    if metadata.notes.to_s.length > 3
      unless metadata.notes.slide_notes.to_s.length <= 1
        notesHash["Slide Notes"]=metadata.notes.slide_notes
      end
      unless metadata.notes.index_notes.to_s.length <= 1
        notesHash["Index Notes"]=metadata.notes.index_notes
      end
    else
      return {}
    end
    return notesHash
  end

  def keywords
    keywordslist=Array.new
    metadata=self.meta
    #print self.meta
    metadata.Keywords.each do |word|
      if word.length > 1
        keywordslist.push word.lstrip.rstrip
      end
    end
    return keywordslist
  end

  def oldNums
    numberlist=Array.new
    metadata=self.meta
    metadata.old_ids.each do |id|
      if id.length > 1
        numberlist.push id.lstrip.rstrip
      end
    end
    return numberlist
  end

  def locations
    rtnHash=Hash.new
    lochash=Hash.new
    metadata=self.meta
    (gencoords,speccoords,objectcoords)=[0,0,0]
    metadata.locations.each do |loc|
      if loc.type=="general" and loc.title.to_s.length > 1
        lochash["General Location"]=loc.title
        gencoords=formatcoords([loc.coordinates])
      elsif loc.type=="specific" and loc.title.to_s.length > 1
        lochash["Camera Location"]=loc.title
        speccoords=formatcoords([loc.coordinates])
        rtnHash["Extra"]={"Precision" => loc.precision.capitalize,"Angle" => loc.angle,"Degrees"=>stripAngleNum(loc.angle)}
        # print " Additional: #{additional} "
      elsif loc.type=="object" and loc.latitude.to_s.length > 1
        lochash["Object Location"]=""
        objectcoords=formatcoords([loc.latitude,loc.longitude])
      end
    end
    if [gencoords,speccoords].include? objectcoords
      lochash.delete("Object Location")
      objectcoords=0
    end
    rtnHash["Hash"]=lochash
    names=Array.new
    coords=Array.new
    unless objectcoords == 0
      names.push "Object Location"
      coords.push objectcoords
    end
    unless gencoords == 0
      names.push "General Location"
      coords.push gencoords
    end
    unless speccoords == 0
      names.push "Camera Location"
      coords.push speccoords
      #rtnHash["Extra"]=additional
    end
    rtnHash["Array"]=[names,coords]
    return rtnHash
  end
  def stripAngleNum(stringAngle)
    words=stringAngle.split " "
    if words[0].to_i.to_s == words[0]
      return words[0].to_i
    else
      index=0
      degPlace=-1
      words.each do |word|
        if word.downcase == "degrees"
          degPlace=index
        end
        index+=1
      end
      unless degPlace<0
        if words[degPlace-1].to_i.to_s == words[degPlace-1]
          return words[degPlace-1].to_i
        end
      else
        return -1
      end
    end
  end
  def formatcoords(arr)
    if arr.length == 1
      each=arr[0][1...-1].split(",")
    elsif arr.length == 2
      each=arr
    end
    return [each[0].to_f,each[1].to_f]
  end
  def prepJSON
    begin
      json=self.configured_field_t_object_notation[0]
      puts "JSON=#{json}"
      metadata=JSON.parse(json, object_class: OpenStruct)
    rescue
      metadata=OpenStruct.new({"Keywords"=>[],"dates"=>[],"notes"=>[],"locations"=>[]})
    end
    return metadata
  end
#preview methods ########################
  def hasAbstract?
    return self.abstract.to_s.length > 1
  end
  def hasDescription?
    return self.configured_field_t_description.to_s.length > 1
  end
  def hasImageNotes?
    return self.configured_field_t_image_notes.to_s.length > 1
  end
  def hasCuratorNotes?
    return self.configured_field_t_curator_notes.to_s.length > 1
  end
  #the next method tries all the operations that could throw errors to check incoming slides
  def detectErrors
    self.meta=self.prepJSON
    valuesToCheck=[ #These values must be possessed by the slide, but may not throw errors when missing
      self.configured_field_t_subcollection,
      self.keywords[0],
      self.cleanTitle,
      self.cleanImageNotes
    ]
    valuesToCheck.each do |val|
      if val.to_s.length < 3
        raise StandardError.new
      end
    end
    #the following values can be empty, but there cannot be errors when they are requested
    self.dates
    self.locations
    self.year
    self.oldNums
  end
  private
#constructor methods ##########################
  def getImgLinks(sampleLink)
    linkComponents=sampleLink.split("/")
    posGuess=linkComponents[6]
    unless posGuess.to_i.to_s == posGuess
      linkComponents.each do |guess|
        print "First Guess: #{posGuess}, new guess: #{guess}"
        if guess.to_i.to_s == guess
          posGuess=guess
          break
        end
      end
    end
    newMedLink="https://digital.kenyon.edu/baly/#{posGuess}/preview.jpg"
    newThmLink="https://digital.kenyon.edu/baly/#{posGuess}/thumbnail.jpg"
    return [newMedLink,newThmLink]
  end

  def cleantext(text)
    if text.include?(">") and text.include?("<")
      start=text.index(">")+1
      last=text.rindex("<")
      clipped=text[start...last]
    else
      clipped=text
    end
    return clipped.to_s.lstrip.rstrip
  end

  def prepYear
    cdate=Date.parse self.publication_date
    return cdate.year.to_s
  end
end