class CreateCollections < ActiveRecord::Migration[7.1]
  def change
    create_table :collections do |t|
      t.string :title
      t.text :description
      t.string :img_link

      t.timestamps
    end
  end
end
