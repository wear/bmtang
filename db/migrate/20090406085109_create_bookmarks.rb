class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.integer :group_id
      t.integer :wiki_page_id 
      t.integer :user_id
      t.string :content

      t.timestamps
    end
          add_index "bookmarks", ["group_id", "wiki_page_id","user_id"], :name => "bookmarks_group_id_wiki_page_id_user_id"
  end

  def self.down
    drop_table :bookmarks
  end
end
