class CollectionsController < ApplicationController
  def index
    @collections=Collection.order :alph_value
  end

  def show
    number=params[:alph]
    @collection=Collection.find_by alph_value: number
    @yearsincluded=@collection.previews.extract_associated(:year)
    print @yearsincluded
  end
end
