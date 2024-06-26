class CreateSlides < ActiveRecord::Migration[7.1]
  def change
    create_table :slides do |t|

      t.timestamps
    end
  end
end
