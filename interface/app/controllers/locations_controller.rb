class LocationsController < ApplicationController
  def show
    id=params[:id]
    @location=Location.find(id)
    @mapHash=@location.generateMapArrays
  end
end
