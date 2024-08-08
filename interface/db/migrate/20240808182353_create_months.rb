class CreateMonths < ActiveRecord::Migration[7.1]
  def change
    create_table :months do |t|
      t.string :title
      t.integer :number
      t.references :year, null: false, foreign_key: true

      t.timestamps
    end
  end
end
