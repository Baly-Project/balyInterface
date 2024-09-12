class KeywordsController < ApplicationController
  def index
    @keywords=Keyword.all
    @periods=Keyword.first.getPeriods
    @periodObjects=assembleHash(@periods)
  end

  def show
    id=params[:id]
    @keyword=Keyword.find(id)
  end

  def assembleHash(periods)
    titles=Array.new
    periods.each do |key,list|
      titles+=list
    end
    words=Keyword.where(:title => titles).pluck(:title,:id)
    return words.to_h
  end
end

