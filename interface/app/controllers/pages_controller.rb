class PagesController < ApplicationController
  def home 
  end

  def timeline
    ui=CustomPattern.new
    @timeline=ui.timeline
  end

  def about
  end
end
