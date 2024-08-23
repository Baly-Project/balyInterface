class Collection < ApplicationRecord
  has_many :previews

  def getRandomImage
    unfound=true
    (self.previews.size*3).times do |i|
      preview=self.previews.sample
      if preview.orientation == "L"
        return preview
        unfound=falsex
      end
    end
  end
end
