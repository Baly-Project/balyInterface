namespace :record do 
  desc "read all slides from DK api and save necessary data"
  task update: :environment do 
    json_data=Faraday.get(Faraday.get(
      "https://content-out.bepress.com/v2/digital.kenyon.edu/query",
      {parent_key: '5047491',limit: 50000, select_fields: 'all'},
      {'Authorization' => 'MPqsb8Pd9+YxLgTIC638nB2h0m7vNjyIPzC009gUru8='}).env.response_headers['location']
    )
    parsed=JSON.parse(json_data.body, object_class: Slide)
    count=parsed.query_meta.total_hits
    puts "#{count} slides read"
    objects=parsed.results
    slides=Array.new
    objects.each do |obj|
      begin
        obj.detectErrors
        slides.push obj
      rescue
        puts "#{obj} did not pass error checking. Update the record on Digital Kenyon"
      end
    end
    puts "#{slides.length} slides passed, #{slides}"
  end
end
