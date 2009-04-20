class AddWiki < ActiveRecord::Migration
  def self.up
    create_table "wiki_content_versions", :force => true do |t|
      t.integer  "wiki_content_id",                              :null => false
      t.integer  "page_id",                                      :null => false
      t.integer  "author_id"
      t.binary   "data"
      t.string   "compression",     :limit => 6, :default => ""
      t.string   "comments",                     :default => ""
      t.datetime "updated_on",                                   :null => false
      t.integer  "version",                                      :null => false
    end

    add_index "wiki_content_versions", ["wiki_content_id"], :name => "wiki_content_versions_wcid"

    create_table "wiki_contents", :force => true do |t|
      t.integer  "page_id",                    :null => false
      t.integer  "author_id"
      t.text     "text"
      t.string   "comments",   :default => ""
      t.datetime "updated_on",                 :null => false
      t.integer  "version",                    :null => false
    end

    add_index "wiki_contents", ["page_id"], :name => "wiki_contents_page_id"

    create_table "wiki_pages", :force => true do |t|
      t.integer  "wiki_id",                       :null => false
      t.string   "title",                         :null => false
      t.datetime "created_on",                    :null => false
      t.boolean  "protected",  :default => false, :null => false
      t.integer  "parent_id"
    end

    add_index "wiki_pages", ["wiki_id", "title"], :name => "wiki_pages_wiki_id_title"

    create_table "wiki_redirects", :force => true do |t|
      t.integer  "wiki_id",      :null => false
      t.string   "title"
      t.string   "redirects_to"
      t.datetime "created_on",   :null => false
    end

    add_index "wiki_redirects", ["wiki_id", "title"], :name => "wiki_redirects_wiki_id_title"

    create_table "wikis", :force => true do |t|
      t.integer "group_id",                :null => false
      t.string  "start_page",                :null => false
      t.integer "status",     :default => 1, :null => false
    end

    add_index "wikis", ["group_id"], :name => "wikis_group_id"
  end

  def self.down
    drop_table :wikis 
    drop_table :wiki_pages
    drop_table :wiki_contents
    drop_table :wiki_content_versions
    drop_table :wiki_redirects 
  end
end
