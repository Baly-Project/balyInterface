class AddCoordinatesToPreviews < ActiveRecord::Migration[7.1]
  def change
    add_column :previews, :coordinates, :string
  end
end
