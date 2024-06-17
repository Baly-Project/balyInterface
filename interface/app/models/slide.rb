class Slide < OpenStruct

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


  private

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
end
