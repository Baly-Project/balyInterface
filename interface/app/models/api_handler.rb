class ApiHandler
  def getRecord(target:0,fields:'all',parsed:false,maxtries:5,check:[],query:"")
    fieldHash=prepareFields(target,fields,query)
    tries=0
    while tries < maxtries
      json_data=Faraday.get(Faraday.get(
        "https://content-out.bepress.com/v2/digital.kenyon.edu/query",
        fieldHash,
        #fields: "title,abstract,url,download_link,publication_date,configured_field_t_identifier,configured_field_t_alternate_identifier,configured_field_t_creation_year,configured_field_t_subcollection,configured_field_t_city,configured_field_t_country,configured_field_t_coverage_spatial,configured_field_t_image_notes,configured_field_t_curator_notes,configured_field_t_sorting_numbers"},
        {'Authorization' => 'MPqsb8Pd9+YxLgTIC638nB2h0m7vNjyIPzC009gUru8='}).env.response_headers['location']
      )
      json=json_data.body
      results=JSON.parse(json,object_class: Slide)
      slides=results.results
      count=results.query_meta.total_hits
      attrsPresent=checkPresence?(slides,check)
      if count == 0 or attrsPresent==false
        tries +=1
        finaljson=nil
        puts "Try ##{tries} failed to deliver."
        if tries < maxtries
          puts "Trying again..."
        else
          return slides
        end
      else
        tries+=maxtries
        finaljson=json
      end
    end
    #puts "data collected"
    if finaljson.class == NilClass
      puts "JSON was not delivered after #{maxtries} tries. Check target value."
      return ""
    else
      #puts "data present"
      if parsed
        if target == 0
          return slides
        else
          return slides[0]
        end
      else
        return finaljson
      end
    end
  end
  private
  
  FieldLists={"display"=>"title,abstract,configured_field_t_description,configured_field_t_references,download_link,url,configured_field_t_sorting_number,configured_field_t_identifier,configured_field_t_alternate_identifier,configured_field_t_coverage_spatial,configured_field_t_image_notes,configured_field_t_curator_notes,configured_field_t_object_notation",
              "min" => "title,configured_field_t_identifier,configured_field_t_sorting_number"}
  def prepareFields(target,fields,query)
    startHash={parent_key: 5047491}
    if target==0
      startHash=startHash.merge({limit: 10000})
      if query != ""
        startHash=startHash.merge({q:query})
      end
    else
      startHash=startHash.merge({configured_field_t_sorting_number: target, limit: 1})
    end
    if FieldLists.keys.include? fields
      startHash=startHash.merge({fields:FieldLists[fields]})
    else
      if fields!="all"
        puts "The fields option '#{fields}' is not recognized. All fields have been returned."
      end
      startHash=startHash.merge({select_fields:"all"})
    end
    print startHash
    return startHash
  end  
  def checkPresence?(slides,symArray)
    if symArray.length < 1
      return true
    end
    symHash=Hash.new
    symArray.each do |sym|
      symHash[sym]=false
      iterator=0
      max=slides.length
      while iterator < max
        slide=slides[iterator]
        #puts slide,slide[sym]
        if slide[sym].to_s.length > 0
          symHash[sym]=true
          iterator+=max
        else
          iterator += 1
        end
      end
    end
    symHash.each do |sym,bool|
      if bool == false
        return false
      end
    end
    return true
  end
end
