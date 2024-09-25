class SearchController < ApplicationController
  API=ApiHandler.new

  def query
    q=params[:query]
    rawrecords=API.getRecord(fields:"display",query:q,parsed:true)
    records=Array.new
    rawrecords.each do |raw|
      if raw.hasSortingNumber?
        begin
          Preview.find_by! sorting_number:raw.sortingNumber
          records.push raw
        rescue
          puts "Slide #{raw.id} has a sorting number but is not in the gallery. An update should be performed at the next possible opportunity"
        end
      end
    end
    @query=q
    @records=records
  end
end
