class SlidesController < ApplicationController
  API=ApiHandler.new
  def index
    sortparam=params[:sortparam]
    @start=params[:start].to_i
    @last=params[:last].to_i
    if sortparam.class == NilClass
      sortparam="title"
    end
    @count=Preview.all.size
    if sortparam == "title"
      @previews=Preview.order(:title)[@start..@last]
    elsif sortparam == "date"
      @previews=Preview.order(year.number,month.number)[@start..@last] 
    elsif sortparam == "country"
      @previews=Preview.order(country.title)[@start..@last]
    end
  end

  def show
    number=params[:id]
    @slide=API.getRecord(target:number,fields:"display",parsed:true,check:[:configured_field_t_sorting_number],maxtries:10)
    @slide.prepJSON
    @preview=Preview.find_by(sorting_number:number)
  end
    
end
