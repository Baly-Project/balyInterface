class Collection < ApplicationRecord
  has_many :previews

  def getRandomImage
    begin
      sample=self.previews.find_by! orientation:"L"
      unfound=true
      (self.previews.size*3).times do |i|
        preview=self.previews.sample
        if preview.orientation == "L"
          return preview
          unfound=false
        end
      end
      return sample
    rescue
      return self.previews.sample
    end
  end

  def generateSearchEntry
    link = "collections/#{self.alph_value}"
    title = self.title
    return [title,link]
  end
end
