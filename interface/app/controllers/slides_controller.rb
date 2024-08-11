class SlidesController < ApplicationController
  API=ApiHandler.new
  def index
    sortparam=params[:sortparam]
    @start=params[:start].to_i
    @last=params[:last].to_i
    if sortparam.class == NilClass
      sortparam="title"
    end
    objects=API.getRecord(parsed:true)
    @count=objects.length    
    if sortparam == "title"
      @slides=objects.sort_by {|a| a.title}
    elsif sortparam == "date"
      @slides=objects.sort_by {|a| a.date} 
    elsif sortparam == "upload_date"
      @slides=objects.sort_by {|a| a.url}
    end
  end

  def show
    number=params[:id]
    @slide=API.getRecord(target:number,fields:"display",parsed:true,check:[:configured_field_t_sorting_number])
    @slide.prepJSON
    @preview=Preview.find_by(sorting_number:number)
  end
    
end
