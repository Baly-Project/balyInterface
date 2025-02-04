class CreateCities < ActiveRecord::Migration[7.1]
  def change
    create_table :cities do |t|
      t.string :title
      t.references :region, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
  end
end
