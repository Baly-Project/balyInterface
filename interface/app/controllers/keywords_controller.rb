class KeywordsController < ApplicationController
  def index
    @keywords=Keyword.all.sort_by {|kw| kw.previews.length}
  end

  def show
    id=params[:id]
    @keyword=Keyword.find(id)
  end
end
