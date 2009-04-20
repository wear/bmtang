class AddMissingIndex < ActiveRecord::Migration
  def self.up
    add_index "assets", ["attachable_type"], :name => "asset_attachable_type" 
    add_index "assets", ["attachable_id"], :name => "asset_attachable_id"
    add_index "groups", ["created_at"], :name => "group_created_at"
    add_index "groups", ["created_by"], :name => "group_created_by"
    add_index "memberships", ["user_id"], :name => "memberships_user_id"
    add_index "memberships", ["group_id"], :name => "memberships_group_id"
    add_index "posts", ["group_id"], :name => "posts_group_id"     
  end

  def self.down
  end
end
