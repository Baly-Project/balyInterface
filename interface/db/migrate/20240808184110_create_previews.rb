class CreatePreviews < ActiveRecord::Migration[7.1]
  def change
    create_table :previews do |t|
      t.string :title
      t.integer :sorting_number
      t.string :description
      t.string :img_link
      t.references :collection, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.references :region, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true
      t.references :stamp, null: false, foreign_key: true
      t.references :month, null: false, foreign_key: true
      t.references :year, null: false, foreign_key: true

      t.timestamps
    end
  end
end
