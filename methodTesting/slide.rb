require 'ostruct'
require 'json'
require_relative 'flexdate.rb'
#This is a copy of the slide.rb file from the interface app, stored in interface/app/models
class Slide < OpenStruct
#Accessor Methods ####################
  def sortingNumber
    return self.configured_field_t_sorting_number[0].to_i
  end
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

  def makePreview(char_limit:30)
    if hasAbstract?
      preview=cleanAbstract
    elsif hasDescription?
      preview=cleanDescription
    else
      preview=generateConciseNotes
    end
    if preview.length > char_limit
      cut=preview[0...char_limit]
      finished=cut+"..."
    else 
      finished=preview
    end
    return finished
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
  
  def id
    return self.configured_field_t_identifier[0]
  end

  def altID
    return self.configured_field_t_alternate_identifier[0]
  end

  def city
    return self.configured_field_t_city    
  end
  def region
    begin 
      return self.configured_field_t_region
    rescue
      return ""
    end
  end
  def country
    return self.configured_field_t_country
  end
  def subcollection
    return self.configured_field_t_subcollection[0]
  end
  def batchStamp
    begin
      return self.configured_field_t_batch_stamp[0]
    rescue
      return ""
    end
  end
  def year
    return prepYear
  end

  def dates
    datesHash=Hash.new
    if hasJSONinfo?
      metadata=self.meta
      if metadata.dates.to_s.length > 1
        dateinfo=metadata.dates
        dateinfo.each do |date|
          if date.year.to_s.length > 3
            datesHash[date.type.capitalize+" Date"]=Flexdate.new(date)
          end
        end
      end
    end
    return datesHash
  end

  def notes
    notesHash=Hash.new
    if hasJSONinfo?
      metadata=self.meta
      if metadata.notes.to_s.length > 1
        unless metadata.notes.slide_notes.to_s.length <= 1
        notesHash["Slide Notes"]=metadata.notes.slide_notes
        end 
        unless metadata.notes.index_notes.to_s.length <= 1
        notesHash["Index Notes"]=metadata.notes.index_notes
        end
      end
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

  def altTerms
    altTerms=Array.new
    metadata=self.meta
    if metadata.search_terms.to_s.length > 0
      words=metadata.search_terms[0].split ";"
      words.each do |word|
        if word.length > 1
          altTerms.push word.lstrip.rstrip
        end
      end
    end
    return altTerms
  end
  def oldNums
    numberlist=Array.new
    metadata=self.meta
    if metadata.old_ids.to_s.length>0
        metadata.old_ids.each do |id|
        if id.length > 1
          numberlist.push id.lstrip.rstrip
        end
      end
    end
    return numberlist
  end

  def locations(general:false,specificCoords:false)
    rtnHash=Hash.new
    lochash=Hash.new
    metadata=self.meta
    (gencoords,speccoords,objectcoords)=[0,0,0]
    if metadata.locations.to_s.length > 1
        metadata.locations.each do |loc|
        if loc.type=="general" and loc.title.to_s.length > 1
          lochash["General Location"]=loc.title
          gencoords=formatcoords([loc.coordinates])
          if general
            return [loc.title,loc.coordinates]
          end
        elsif loc.type=="specific" and loc.title.to_s.length > 1
          lochash["Camera Location"]=loc.title
          speccoords=formatcoords([loc.coordinates])
          if specificCoords
            return speccoords
          end
          rtnHash["Extra"]={"Precision" => loc.precision.capitalize,"Angle" => loc.angle,"Degrees"=>stripAngleNum(loc.angle)}
          # print " Additional: #{additional} "
        elsif loc.type=="object" and loc.latitude.to_s.length > 1
          lochash["Object Location"]=""
          objectcoords=formatcoords([loc.latitude,loc.longitude])
        end
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
    unless general or specificCoords
      return rtnHash
    end
    if general
      return ["",""]
    elsif specificCoords
      return ""
    end
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
    unless self.hasJSONinfo?
      json=self.configured_field_t_object_notation[0]
      self.meta=JSON.parse(json, object_class: OpenStruct)
      self.configured_field_t_object_notation=""
    end 
  end
#Preview methods ########################
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
  def hasJSONinfo?
    return self.meta.to_s.length > 1
  end
  def hasSortingNumber?
    return self.configured_field_t_sorting_number.to_s.length > 2
  end
  #the next method tries all the operations that could throw errors to check incoming slides
  def detectErrors
    self.prepJSON
    valuesToCheck=[ #These values must be possessed by the slide, but may not throw errors when missing
      [self.configured_field_t_subcollection,"Subcollection"],
      [self.keywords[0],"Keywords"],
      [self.cleanTitle, "Title"],
      [self.cleanImageNotes,"Image Notes"]
    ]
    valuesToCheck.each do |valarray|
      if valarray[0].to_s.length < 3
        raise StandardError.new ("#{valarray[1]} value '#{valarray[0]}' is empty or could not be read")
      end
    end
    #the following values can be empty, but there cannot be errors when they are requested
    self.dates
    self.locations
    self.year
    self.oldNums
    return true
  end
  private
#Constructor methods ##########################
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

  def generateConciseNotes
    notes=String.new
    date=self.configured_field_t_documented_date[0]
    notes+="Created in #{date}. "
    collection=subcollection
    notes+="Part of #{collection}. "
    location=self.configured_field_t_coverage_spatial[0]
    notes+="Located in #{location}"
    return notes
  end
end
