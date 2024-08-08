class CreateRegions < ActiveRecord::Migration[7.1]
  def change
    create_table :regions do |t|
      t.string :title
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
  end
end
