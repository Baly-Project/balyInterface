class CountriesController < ApplicationController
  def index
    @countries=Country.order(:title)
  end

  def show
    id=params[:id]
    @country=Country.find_by(id:id)
  end
end
