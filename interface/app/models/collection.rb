class Collection < ApplicationRecord
  has_many :previews

  def getRandomImage
    unfound=true
    (self.previews.size*3).times do |i|
      preview=self.previews.sample
      dims=FastImage.size(preview.img_link)
      if dims[0] > dims[1]
        return preview
        unfound=false
      end
    end
  end
end
