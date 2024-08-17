class CreateKeywords < ActiveRecord::Migration[7.1]
  def change
    create_table :keywords do |t|
      t.string :title
      t.string :super
      t.string :alternates

      t.timestamps
    end
  end
end
