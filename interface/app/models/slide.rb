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
  
  def year
    return prepYear
  end

  def dates
    datesHash=Hash.new
    metadata=prepJSON
    dateinfo=metadata.date
    dateinfo.each do |date|
      datesHash[date.type]=Flexdate.new(date)
    end
    return datesHash
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

  def prepJSON
    dirty=self.configured_field_t_sorting_numbers[0]
    clean=dirty.split(" - ")[1].lstrip
    metadata=JSON.parse(clean, object_class: OpenStruct)
    return metadata
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
