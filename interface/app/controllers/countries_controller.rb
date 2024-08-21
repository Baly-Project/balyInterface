class CountriesController < ApplicationController
  def index
    @countries=Country.order(:title)
    locations=Location.all
    (locCoords,locLabels,locScales) = [Array.new,Array.new,Array.new]
    locations.each do |loc|
      if loc.coordinates.include? ","
      	locCoords.push loc.prepcoords(loc.coordinates)
        label="<a class='purple' href='/places/locations/"
        label+= loc.id.to_s
        label+="'> #{loc.title} </a>"
        locsize=loc.previews.size
        label+="<br> #{locsize} slides"
        locLabels.push label
        scale=(locsize*0.0125) + 0.5
        locScales.push scale
      end
    end
    @mapHash={coordinates:locCoords,labels:locLabels,scales:locScales}
  end

  def show
    id=params[:id]
    @country=Country.find_by(id:id)
  end
end
