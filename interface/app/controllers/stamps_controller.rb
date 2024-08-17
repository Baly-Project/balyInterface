class StampsController < ApplicationController
  def index
    dater=EnhancedDate.new
    @stamps=Stamp.all.sort_by {|stamp| dater.parseStamp(stamp.title)[:year]}
  end

  def show
    id=params[:id]
    @stamp=Stamp.find(id)
  end
end
