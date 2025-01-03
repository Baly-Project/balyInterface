class SlidesController < ApplicationController
  API=ApiHandler.new
  def index
    sortparam = params[:sortparam]
    @start = params[:start].to_i-1
    @last = params[:last].to_i-1
    if sortparam.class == NilClass
      sortparam = "title"
    end
    @count = Preview.all.size
    if sortparam == "title"
      previews = Preview.order(:sorting_number)
    elsif sortparam == "date"
      previews = Preview.eager_load(:year,:month).sort_by{|prev| prev.year.number*20+prev.month.number}
    elsif sortparam == "country"
      previews = Preview.eager_load(:country).sort_by{|prev| prev.country.title}
    elsif sortparam == "random"
      previews = Preview.all.shuffle
    end
    @sortparam = sortparam
    @previews = previews[@start..@last]
    @allIds = previews.pluck(:sorting_number)
  end

  def range
    range = params[:range]
    (first,last) = range.split("-")
    @previews = Preview.where(sorting_number:(first..last))
  end
    
  def show
    number = params[:id]
    @preview = Preview.find_by(sorting_number:number)
  end

  def load
    number = params[:id]
    @slide = API.getRecord(target:number,fields:"display",parsed:true,check:[:configured_field_t_sorting_number],maxtries:10)
    @slide.prepJSON
 #   respond_to do |format|
#      format.turbo_stream do 
   #     render turbo_stream: [
  #        turbo_stream.replace('carousel', partial: 'carousel', object: @slide),
 #         turbo_stream.replace('description' ,partial: 'descriptions', object: @slide),
#	  turbo_stream.replace('map' ,partial:'map', object: @slide)
   #     ]
  #    end
#    end
  end
end
