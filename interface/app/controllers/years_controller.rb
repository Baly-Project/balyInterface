class YearsController < ApplicationController

  def show
    @year=Year.find_by(number:params[:number])
  end
end
