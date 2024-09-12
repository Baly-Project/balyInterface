class AddAlphValueToCollections < ActiveRecord::Migration[7.1]
  def change
    add_column :collections, :alph_value, :integer
  end
end
