class CustomPattern
  #this is a user-input class that forces screening of patterns before they are displayed
  #Updates must occur on this file (the version in interface/app/models)
  
  
# The first hash represents keywords that are completely included within others.
# This should be reserved for logical subsets and avoid coincidences.
# To update, generate the possible subsets by opening a terminal, entering irb, and loading 
# methods.rb. Then type collectKeywordPatterns and hit enter, and a list of all the possible 
# patterns present in the digital kenyon data will appear. Then copy/paste lines directly into this
  
  KeywordSubsets={
    "Walls of Jerusalem"=>"Walls",
    "Northern Arcade of Temple Mount"=>"Arcade",
    "Quranic Inscription"=>"Arabic Inscription",
    "Arabic Inscription"=>"Inscription",
    "Portico"=>"Columns",
    "Dome of the Ascension"=>"Dome",
    "Northeast Arcade of Temple Mount"=>"Arcade",
    "Dome of the Spirits"=>"Dome",
    "Staircase"=>"Steps",
    "Engaged Columns"=>"Columns",
    "Golden Gate"=>"Gates of the Temple Mount",
    "Ashlar"=>"Masonry",
    "Sebil Ala ad Din el Basir"=>"Fountain",
    "Ecce Homo Basilica"=>"Nineteenth Century",
    "Ecce Homo Arch"=>"Nineteenth Century",
    "Madrasa Is’ardiyya"=>"Madrasa",
    "Muslim Quarter"=>"Jerusalem",
    "Dome of the Prophet's Lovers"=>"Mamluk",
    "Dome of Moses"=>"Ayyubid",
    "Sebil Qait Bay"=>"Ayyubid",
    "Sebil Qasim Pasha"=>"Ayyubid"
  }

  KeywordTerms={ #this should correspond with the keyword translations document in the drive.
    #Like the keyword translation document, these are sorted by collection
    # A: Jerusalem
    "Dome of the Rock"=>"Qubbat as-Sakhrah",
    "Temple Mount"=>"Haram al-Sharif, Holy Esplanade",
    "Dome of the Ascension"=>"Qubbat al-Miraj",
    "Dome of the Spirits"=>"Qubbat al-Arwah",
    "Chain Gate Minaret"=>"Bab el-Silsileh Minaret, Bab el-Silsila Minaret",
    "Gate of the Chain"=>"Bab el-Silsileh Minaret, Bab el-Silsila Minaret",
    "Minbar al-Sayf"=>"Minbar of Burhan al-Din, Summer Pulpit",
    "Qubba al-Nahw"=>
    "Nahawiyya Madrasa, Dome of Grammar, Qubbat al-Nahawiyya, al-Rusasiyya, al-Mu'azzamiyya, Qubbat al-Hanabila, al-Madrasa al-Nahawiyya",
    "Golden Gate"=>"Bab al-Zahabi",
    "Qait Bay"=>"Qaytbay, Qait Bay, Qayt Bay",
    "Bab al-Qattanin"=>"Cotton Merchant's Gate",
    "Ecce Homo Basilica"=>"Convent of the Sisters of Zion",
    "Dome of the Prophet's Lovers"=>"Iwan of Sultan Mahmud II",
    "Dome of Moses"=>"Dome of Musa, Dome of the Tree, Qubbat al-Musa",
    "Dome of Solomon"=>"Qubbat Sulayman",
    "King Faisal's Gate"=>"Gate of Darkness, Bab e Shah Faisal",
    "Chain Gate" => "Bab el-Silsileh, Bab el-Silsila",
    "Chain Gate Street" => "Bab el-Silsileh Street, Bab el-Silsila Street",
    "Chain Gate Fountain" => "Sabil Bab el-Silsileh, Bab el-Silsila",
    "Gate of the Bani Ghanim"=>"Iwan of Sultan Mahmud, Ghawanima Gate",
    "Sebil of Suleiman"=>"Sebil e bab e Attim",
    "Cotton Merchant's Gate"=>"Bab al-Qattanin",
    "Fountain" => "Sabil, Sebil",
    "Dome" => "Qubba, Qubbat",
    "Mosque" => "Masjid",
    "Tomb"=>"Turba, Turbat"
  }

  KeywordPeriods={
    #A collection of special keywords referring to time intervals that must be given an order.
    #The centuries list should be more or less fixed, but can be expanded if need be.
    #The periods list should refer to formal archaeological time periods, and distinct 
    #archaeological traditions should be kept separate.
    #These will only display if the keywords are found within the collection.  
    "Period" => [
      "Archaic Period",
      "Classical Period",
      "Early Hellenistic Period",
      "Hellenistic Period",
      "Roman Period",
      "Byzantine Period"
    ],
    "Century" => [
      "Tenth Century BC",
      "Ninth Century BC",
      "Eighth Century BC",
      "Seventh Century BC",
      "Sixth Century BC",
      "Fifth Century BC",
      "Fourth Century BC",
      "Third Century BC",
      "Second Century BC",
      "First Century BC",
      "First Century AD",
      "Second Century AD",
      "Third Century AD",
      "Fourth Century AD",
      "Fifth Century AD",
      "Sixth Century AD",
      "Seventh Century AD",
      "Eighth Century AD",
      "Ninth Century AD",
      "Tenth Century",
      "Eleventh Century",
      "Twelfth Century",
      "Thirteenth Century",
      "Fourteenth Century",
      "Fifteenth Century",
      "Sixteenth Century",
      "Seventeenth Century",
      "Eighteenth Century",
      "Nineteenth Century",
      "Twentieth Century"
    ]
  }

  def keywordSubsets
    return KeywordSubsets
  end

  def keywordTerms
    return KeywordTerms
  end

  def returnAll
    return {keywordSubsets:KeywordSubsets,keywordTerms:KeywordTerms}
  end

  def returnPeriodHash
    return KeywordPeriods
  end
end
