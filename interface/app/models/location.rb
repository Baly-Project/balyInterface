class Location < ApplicationRecord
  belongs_to :city
  belongs_to :region
  belongs_to :country
  has_many :previews

  validates :title, presence: true
  validates :coordinates, presence: true

  def generateMapArrays
    coords=[prepcoords(self.coordinates)]
    labels=[self.title]
    scales=[1.4]
    self.previews.each do |preview|
      if preview.coordinates.to_s.length > 2
        coords.push prepcoords(preview.coordinates)
        label="<a class='purple' href='/slides/"
        label+= preview.sorting_number.to_s 
        label+= "' data-action='click->back-forth/#setList'> #{preview.title} </a>"
        labels.push label
        scales.push 1
      end
    end
    return {coordinates:coords,labels:labels,scales:scales}
  end
  def prepcoords(coordstring)
    halves=coordstring.split(",")
    cord1=halves[0][1..-1].to_f
    cord2=halves[1][0...-1].to_f
    arr=[cord1,cord2]
    return arr
  end

  def generateSearchEntry
    link = "/places/locations/#{self.id}"
    title = self.title
    return [title,link]
  end
end
