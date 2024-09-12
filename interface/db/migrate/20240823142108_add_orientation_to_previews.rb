class AddOrientationToPreviews < ActiveRecord::Migration[7.1]
  def change
    add_column :previews, :orientation, :string
  end
end
