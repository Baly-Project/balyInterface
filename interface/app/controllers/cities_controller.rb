class CitiesController < ApplicationController
  def show
    id=params[:id]
    @city=City.find(id)
  end
end
