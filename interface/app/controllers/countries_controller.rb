class CountriesController < ApplicationController
  def index
    @countries = Country.order(:title)
    locations = Location.all
    (locCoords,locLabels,locScales) = [Array.new,Array.new,Array.new]
    locations.each do |loc|
      if loc.coordinates.include? ","
      	locCoords.push loc.prepcoords(loc.coordinates)
        label = "<a class='purple' href='/places/locations/"
        label += loc.id.to_s
        label += "'> #{loc.title} </a>"
        locsize = loc.previews.size
        label += "<br> #{locsize} slides"
        locLabels.push label
        scale = (Math.log(locsize+2.5,6) * 0.4) + 0.2
        locScales.push scale
      end
    end
    @mapHash={coordinates:locCoords,labels:locLabels,scales:locScales}
  end

  def show
    id=params[:id]
    @country=Country.find(id)
  end
end
