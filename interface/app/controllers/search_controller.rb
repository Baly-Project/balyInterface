class SearchController < ApplicationController
  API=ApiHandler.new

  def query
    q=params[:query]
    rawrecords=API.getRecord(fields:"search",query:q,parsed:true)
    records=Array.new
    numbers=Array.new
    countUnshown=0
    rawrecords.each do |raw|
      if raw.hasSortingNumber?
        begin
          number=raw.sortingNumber
          Preview.find_by! sorting_number:number
          records.push raw
          numbers.push number
        rescue
          puts "Slide #{raw.id} has a sorting number but is not in the gallery. An update should be performed at the next possible opportunity"
          countUnshown+=1
        end
      end
    end
    @query=q
    @records=records
    @numbers=numbers
    @unshown=countUnshown
  end
end
