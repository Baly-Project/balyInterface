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
end
