class SearchController < ApplicationController
  API=ApiHandler.new

  def query
    @query=params[:query]
  end

  def get_response
    q=params[:query]
    checkArray=["configured_field_t_identifier","title","configured_field_t_sorting_number"]
    rawrecords=API.getRecord(fields:"search",check:checkArray,query:q,parsed:true)
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
          puts "Slide #{raw} has a sorting number but is not in the gallery. An update should be performed at the next possible opportunity"
          countUnshown+=1
        end
      else
       countUnshown+=1
      end
    end
    @query=q
    @records=records
    @count=records.length
    @numbers=numbers
    @unshown=countUnshown
  end
end
