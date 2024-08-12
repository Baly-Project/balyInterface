class RegionsController < ApplicationController
  def show
    id=params[:id]
    @region=Region.find(id)
  end
end
