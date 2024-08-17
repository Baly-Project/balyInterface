class CreatePreviewsKeywordsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :previews, :keywords do |t|
      t.index :preview_id
      t.index :keyword_id
    end
  end
end
