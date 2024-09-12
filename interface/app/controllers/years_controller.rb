class YearsController < ApplicationController
  def index
    @years=Year.all.sort_by{ |year| year.number}
    yearHash=Hash.new
    #years.each do |year|
    #  monthHash=Array.new
    #  year.months.each do |month|
    #    monthHash=
    #  yearHash[year.number]=
  end
  def show
    @year=Year.find_by(number:params[:number])
  end
end
