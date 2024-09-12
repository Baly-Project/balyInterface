class AddCoordinatesToLocations < ActiveRecord::Migration[7.1]
  def change
    add_column :locations, :coordinates, :string
  end
end
