class Collection < ApplicationRecord
  has_many :previews

  def generateSearchEntry
    link = "/collections/#{self.alph_value}"
    title = self.title
    return [title,link]
  end
end
