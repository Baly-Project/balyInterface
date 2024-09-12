class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.string :title
      t.string :img_link
      t.string :alt_names
      t.references :city, null: false, foreign_key: true
      t.references :region, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
  end
end
