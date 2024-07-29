class SlidesController < ApplicationController
  def index
    sortparam=params[:sortparam]
    @start=params[:start].to_i
    @last=params[:last].to_i
    if sortparam.class == NilClass
      sortparam="title"
    end
    json_data=Faraday.get(Faraday.get(
      "https://content-out.bepress.com/v2/digital.kenyon.edu/query",
      {parent_key: '5047491',limit: 2000}, 
      {'Authorization' => 'MPqsb8Pd9+YxLgTIC638nB2h0m7vNjyIPzC009gUru8='}).env.response_headers['location']
    )
    parsed=JSON.parse(json_data.body, object_class: Slide)
    @count=parsed.query_meta.total_hits
    objects=parsed.results    
    if sortparam == "title"
      @slides=objects.sort_by {|a| a.title}
    elsif sortparam == "date"
      @slides=objects.sort_by {|a| a.date} 
    elsif sortparam == "upload_date"
      @slides=objects.sort_by {|a| a.url}
    end
  end

  def show
    target=params[:id]
    json_data=Faraday.get(Faraday.get(
      "https://content-out.bepress.com/v2/digital.kenyon.edu/query",
      {parent_key: 5047491, configured_field_t_sorting_number: target, limit: 1, 
       fields: "title,abstract,download_link,fulltext_url,publication_date,configured_field_t_identifier,configured_field_t_alternate_identifier,configured_field_t_creation_year,configured_field_t_subcollection,configured_field_t_city,configured_field_t_country,configured_field_t_coverage_spatial,configured_field_t_image_notes,configured_field_t_curator_notes,configured_field_t_sorting_numbers"}, 
      {'Authorization' => 'MPqsb8Pd9+YxLgTIC638nB2h0m7vNjyIPzC009gUru8='}).env.response_headers['location']
    )
    parsed=JSON.parse(json_data.body, object_class: Slide)
    @slide=parsed.results[0]
    @slide.meta=@slide.prepJSON
  end
    
end
