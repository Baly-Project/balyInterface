## Testing and Record of methods used in BalyInterface ##

#gems to require that are autoloaded in the interface app. 
 #(don't include these in any files on the app)
require 'ostruct'
require 'faraday'
require 'json'
#getImgLinks
# need to get thumbnail and medium image links from standard download link.
#
# That is, we need to get from 
sampleImgLink="https://digital.kenyon.edu/context/article/1010/type/native/viewcontent"
# to
resultImgLinks=[
  "https://digital.kenyon.edu/baly/1010/preview.jpg",
  "https://digital.kenyon.edu/baly/1010/thumbnail.jpg"
]
#the number seems consistent across all entries, if it is not, there will be issues.
# Therefore we need to pull the number out and construct the new link

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
print getImgLinks(sampleImgLink)




# this is a load of the Flexdate and Slide model as found in interface/app/models/slide.rb on 7/30/2024
class Flexdate
  def initialize(array)
    if array.class==OpenStruct
      arr=arrayFromStruct(array)
    elsif array.class == Array
      arr=array[0..-1]
    else
      raise StandardError.new "The invalid object #{array} was passed into Flexdate params"
    end
    existing=Array.new
    arr.each do |item|
      unless item.include?("-") or item.length<1
        existing.push item
      end
    end
    numentries=existing.length
    @numattrs=numentries
    if numentries == 3
      (@day,@month,@year)=existing
    elsif numentries == 2
      (@month,@year)=existing
    elsif numentries == 1
      @year=existing[0]
    else
      @numattrs=0
    end
  end

  def displayable?
    return @numattrs > 0
  end

  def to_s
    if @numattrs == 2
      return @month+", "+@year
    elsif @numattrs == 0
      raise StandardError.new "An empty date is being displayed"
    elsif @numattrs == 1
      return @year
    elsif @numattrs == 3
      return @month+" "+@day+", "+@year
    end
  end
  
  private
  
  def arrayFromStruct(aStruct)
    array=Array.new
    hashform=aStruct.to_h
    [:day,:month,:year].each do |attr|
      value=hashform[attr]
      if value.class == String
        array.push value
      end 
    end
    return array
  end      
end
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
    unless metadata.notes.slide_notes.to_s.length <= 1
      notesHash["Slide Notes"]=metadata.notes.slide_notes
    end 
    unless metadata.notes.index_notes.to_s.length <= 1
      notesHash["Index Notes"]=metadata.notes.index_notes
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
    json=self.configured_field_t_object_notation[0]
    metadata=JSON.parse(json, object_class: OpenStruct)
    return metadata
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
  #the next method tries all the operations that could throw errors to check incoming slides
  def detectErrors
    self.meta=self.prepJSON
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
end

class Hash
  def increment(key,val)
    if self.keys.include? key
      self[key].push val
    elsif val.to_s.length > 0
      self[key]=[val]
    end
  end
  def incrementUnlessEmpty(key,val,lengthlimit=2)
    if val.to_s.length > lengthlimit
      increment(key,val)
    end
  end
  def appendCRChash(place)
    unless self.keys.include? place
      self[place]=Hash.new
    end
  end
end
class Date 
  Months=["January","February","March","April","May","June","July","August","September","October","November","December"]
  def stringMonth
    return Months[self.month+1]
  end
end
class SampleSlide < Slide
  #the first function grabs a single slide at a given sorting number
  def getJSON(target)
    json_data=Faraday.get(Faraday.get(
    "https://content-out.bepress.com/v2/digital.kenyon.edu/query",
    {parent_key: 5047491, configured_field_t_sorting_number: target, limit: 1, select_fields: "all"},
    
    #fields: "title,abstract,url,download_link,publication_date,configured_field_t_identifier,configured_field_t_alternate_identifier,configured_field_t_creation_year,configured_field_t_subcollection,configured_field_t_city,configured_field_t_country,configured_field_t_coverage_spatial,configured_field_t_image_notes,configured_field_t_curator_notes,configured_field_t_sorting_numbers"},
    {'Authorization' => 'MPqsb8Pd9+YxLgTIC638nB2h0m7vNjyIPzC009gUru8='}).env.response_headers['location']
    )
    return json_data.body
  end
  def getSample(target)
    json=getJSON(target)
    parsed=JSON.parse(json, object_class: SampleSlide)
    slide=parsed.results[0]
    return slide
  end

  ### Update Testing ###
  #
  # NOTE: the text file handling below should be removed before it is put on the rails app.
  def simUpdate(file="none") # The main update function, that is called in the rails app by "rake record:update"
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
      iterator=0
      while iterator < 3
        (objects,count)=getAllRecords()
        puts "#{count} slides read"
        (passed,unpassed,errors)=reportErrorCheck(objects)
        if passed.length > 0
          iterator+=3
        else
          iterator+=1
        end
      end
    end
    data=processSlides(passed)
    #caredata=processSlidesCarefully(unpassed)
    return data #,caredata]
  end
  def getAllRecords()
    json_data=Faraday.get(Faraday.get(
      "https://content-out.bepress.com/v2/digital.kenyon.edu/query",
      {parent_key: '5047491',limit: 50000, select_fields: 'all'},
      {'Authorization' => 'MPqsb8Pd9+YxLgTIC638nB2h0m7vNjyIPzC009gUru8='}).env.response_headers['location']
    )
    parsed=JSON.parse(json_data.body, object_class: Slide)
    count=parsed.query_meta.total_hits
    objects=parsed.results
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
  def processSlides(slides)
    ids=Array.new
    placetoids=Hash.new
    placeinfo=Hash.new
    keywordstoids=Hash.new
    termstoids=Hash.new
    collections=Hash.new
    years=Hash.new
    timeperiods=Hash.new
    stamps=Hash.new
    slides.each do |slide|
      id=slide.sortingNumber
      ids.push id
      processPlaces(placetoids,placeinfo,slide,id)
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
      :keywordIds => keywordstoids,
      :termIds=>termstoids,
      :collections=>collections,
      :years => years,
      :timeperiods => timeperiods,
      :stamps => stamps
    })
  end
  def processPlaces(placetoids,placeinfo,slide,id)
    crcData={:city=>uncover(slide.city),:region=>uncover(slide.region),:country=>uncover(slide.country)}
    crcData.each do |key,value|
      if value == nil
        value=makeEmptyObj(key)
      end
      placetoids.increment(value,id)
    end
    placeinfo.appendCRChash(crcData[:country])
    placeinfo[crcData[:country]].increment(crcData[:region],crcData[:city])
  end
  def processDate(timeperiods,slide,id)
    stringdate=slide.configured_field_t_documented_date[0]
    puts "DATE=#{stringdate}"
    begin
      date=Date.parse(stringdate)
    rescue
      if stringdate.to_i.to_s == stringdate
        date=OpenStruct.new({:year=>stringdate})
      else
        date=""
      end
    end
    if date.class == OpenStruct
      if timeperiods.keys.include? date.year
        timeperiods[date.year].increment("nomonth",id)
      else
        timeperiods[date.year]={"nomonth"=>[id]}
      end
    else
      if timeperiods.keys.include? date.year
        unless timeperiods[date.year].include? date.stringMonth
          timeperiods[date.year].increment(date.stringMonth,id)
        else
          timeperiods[date.year][date.stringMonth].increment id
        end
      else
        timeperiods[date.year]={date.stringMonth=>[id]}
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

# ExampleData (collected 7/29/24) ########################################
  JSONhash={"results"=>
  [{"context_key"=>"9847662",
    "url"=>"http://digital.kenyon.edu/baly/744",
    "peer_reviewed"=>false,
    "parent_key"=>"5047491",
    "parent_link"=>"http://digital.kenyon.edu/baly",
    "site_key"=>"4580553",
    "site_link"=>"http://digital.kenyon.edu",
    "is_digital_commons"=>true,
    "institution_title"=>"Kenyon College",
    "fulltext_url"=>"https://digital.kenyon.edu/context/baly/article/1748/viewcontent",
    "download_format"=>"picture",
    "download_link"=>"https://digital.kenyon.edu/context/baly/article/1748/type/native/viewcontent",
    "publication_key"=>"5047491",
    "publication_title"=>"Denis Baly Image Collection",
    "publication_link"=>"http://digital.kenyon.edu/baly",
    "dc_or_paid_sw"=>true,
    "include_in_network"=>false,
    "embargo_date"=>"1970-01-01T00:00:01Z",
    "mtime"=>"2024-07-23T21:05:17Z",
    "exclude_from_oai"=>false,
    "fields_digest"=>"4f75f61fc87b5b86e647ef93d9877f6ae476bcba",
    "discipline_terminal_key"=>[510],
    "document_type"=>["35mm_slide", "35 mm slide", "35 mm slides"],
    "author"=>["Denis Baly"],
    "ancestor_key"=>["9847662", "5047491", "4580553", "1"],
    "virtual_ancestor_link"=>
    ["http://digitalcommons.bepress.com",
     "http://researchnow.bepress.com",
     "http://digital.kenyon.edu",
     "http://digital.kenyon.edu/depts",
     "http://digital.kenyon.edu/arthistory",
     "http://digital.kenyon.edu/baly",
     "http://teachingcommons.us",
     "http://teachingcommons.us/arts_humanities",
     "http://ohio.researchcommons.org",
     "http://liberalarts.researchcommons.org"],
    "configured_field_t_rights_statements"=>["In Copyright - Non-Commercial Use Permitted", "http://rightsstatements.org/vocab/InC-NC/1.0/"],
    "author_display_lname"=>["Baly"],
    "discipline"=>["Arts and Humanities", "History of Art, Architecture, and Archaeology"],
    "author_display"=>["Denis Baly"],
    "configured_field_t_dpla_type"=>["Image", "Images", "image"],
    "discipline_key_1"=>[510],
    "discipline_key_0"=>[438],
    "virtual_ancestor_key"=>["81989", "82034", "5025010", "7148337", "4580553", "7639796", "7561783", "5047491", "7127169", "5025132"],
    "discipline_1"=>["History of Art, Architecture, and Archaeology"],
    "discipline_0"=>["Arts and Humanities"],
    "ancestor_link"=>["http://digital.kenyon.edu/baly/744", "http://digital.kenyon.edu/baly", "http://digital.kenyon.edu", "http:/"],


    "title"=>"B22.024 Theatre of Dionysus",
    "abstract"=>"<p>Sculpture from the Late Roman \"Bema of Phaedrus\" at the Theatre of Dionysus. The relief depicts scenes from the life of Dionysus. -MA</p>\n",
    "publication_date"=>"1958-01-01T08:00:00Z",
    "configured_field_t_sorting_numbers"=>
     ["{\"dates\":[{\"type\":\"written\",\"day\":\"8th\",\"month\":\"August\",\"year\":\"1958\"},{\"type\":\"printed\",\"month\":\"-\",\"year\":\"\"}],\"old_ids\":[],\"Keywords\":[\"Frieze\",\" Theater of Dionysus\",\" Acropolis\",\" Athenian Acropolis\",\" Sculpture\",\" Stone Sculpture\",\" Marble Sculpture\",\" Relief Sculpture\",\" Red Slides\"],\"locations\":[{\"title\":\"Athens\",\"type\":\"general\",\"coordinates\":\"(37.9838096,23.7275388)\"},{\"title\":\"Frieze in Theatre of Dionysus\",\"type\":\"specific\",\"coordinates\":\"(37.9702916,23.7277956)\",\"precision\":\"estimated\",\"angle\":\"160 degrees S\"},{\"type\":\"object\",\"latitude\":\"37.97026\",\"longitude\":\"23.72781\"}],\"notes\":{\"slide_notes\":\"Athens - Carving in Theatre of Dionysus\",\"index_notes\":\"Theater of Dionysus\"}}"],
    "configured_field_t_image_notes"=>
     ["Photograph created August 8th, 1958. Processing date unknown. Formerly catalogued as B22.024. Notes written on the slide or index: Athens - Carving in Theatre of Dionysus."],
    "configured_field_t_sorting_number"=>["23024"],
    "configured_field_t_city"=>["Athens"],
    "configured_field_t_country"=>["Greece"],
    "configured_field_t_coverage_spatial"=>["Athens, Greece"],
    "configured_field_t_alternate_identifier"=>["B22.024"],
    "configured_field_t_creation_year"=>["August 8, 1958"],
    "configured_field_t_identifier"=>["B22.024"],
    "configured_field_t_subcollection"=>["W - Attika, Crete, Santorini"],
    "configured_field_t_curator_notes"=>
     ["<p>This is one of the images affected by red-shift in the slide pigment, and previous practice displayed these \"pink slides\" in simple black and white. The image has since been color-corrected back to it's original balance, and will be uploaded soon.</p>"]}],
   "query_meta"=>{"total_hits"=>1, "start"=>0, "limit"=>1, "field_params"=>{"include_only"=>{}}}}
################################################
  def fixedSample()
    return JSON.parse(JSONhash.to_json, object_class: SampleSlide).results[0]
  end
end
def loadSamples(jsonfile)
  json=IO.read(jsonfile)
  results=JSON.parse(json, object_class: SampleSlide)
  slides=results.results
  return slides
end