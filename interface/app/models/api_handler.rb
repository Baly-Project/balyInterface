class ApiHandler
  def getJSON(target:0,fields:'all',parsed:false,maxtries:5)
    fieldHash=prepareFields(target,fields)
    tries=0
    while tries < maxtries
      json_data=Faraday.get(Faraday.get(
        "https://content-out.bepress.com/v2/digital.kenyon.edu/query",
        fieldHash,
        #fields: "title,abstract,url,download_link,publication_date,configured_field_t_identifier,configured_field_t_alternate_identifier,configured_field_t_creation_year,configured_field_t_subcollection,configured_field_t_city,configured_field_t_country,configured_field_t_coverage_spatial,configured_field_t_image_notes,configured_field_t_curator_notes,configured_field_t_sorting_numbers"},
        {'Authorization' => 'MPqsb8Pd9+YxLgTIC638nB2h0m7vNjyIPzC009gUru8='}).env.response_headers['location']
      )
      json=json_data.body
      count=JSON.parse(json,object_class:OpenStruct).query_meta.total_hits
      if count == 0
        tries +=1
        finaljson=nil
        puts "Try ##{tries} failed to deliver."
        if tries < maxtries
          puts "Trying again..."
        end
      else
        tries+=maxtries
        finaljson=json
      end
    end
    if finaljson == nil
      puts "JSON was not delivered after #{maxtries} tries. Check target value."
      return ""
    else
      return finaljson
    end
  end
  private
  
  FieldLists={"display"=>"title,abstract,download_link,url,publication_date,configured_field_t_sorting_number,configured_field_t_identifier,configured_field_t_alternate_identifier,configured_field_t_creation_year,configured_field_t_subcollection,configured_field_t_city,configured_field_t_country,configured_field_t_coverage_spatial,configured_field_t_image_notes,configured_field_t_curator_notes,configured_field_t_object_notation",
              "min" => "title,configured_field_t_identifier,configured_field_t_sorting_number"}
  def prepareFields(target,fields)
    startHash={parent_key: 5047491}
    if target==0
      startHash=startHash.merge({limit: 10000})
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
    return startHash
  end
end
