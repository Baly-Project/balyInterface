class CollectionsController < ApplicationController
  def index
    @collections=Collection.order :alph_value
  end

  def show
    number=params[:alph]
    @collection=Collection.find_by alph_value: number
    @yearsincluded=Year.find(Preview.select(:year_id).where(collection_id:1).distinct.pluck(:year_id))
    print @yearsincluded
  end
end
