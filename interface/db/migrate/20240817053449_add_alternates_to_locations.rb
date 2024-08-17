class AddAlternatesToLocations < ActiveRecord::Migration[7.1]
  def change
    add_column :locations, :alternates, :string
  end
end
