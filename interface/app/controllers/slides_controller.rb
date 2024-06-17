class SlidesController < ApplicationController
  def index
    json_data=Faraday.get(Faraday.get(
      "https://content-out.bepress.com/v2/digital.kenyon.edu/query",
      {parent_key: '5047491'}, 
      {'Authorization' => 'MPqsb8Pd9+YxLgTIC638nB2h0m7vNjyIPzC009gUru8='}).env.response_headers['location']
    )
    objects=JSON.parse(json_data.body, object_class: Slide).results
    @slides=objects
  end
end
