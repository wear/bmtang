class GroupAuth < ActiveRecord::Migration
  def self.up 
    add_column :groups, :member_auth, :boolean,:default => false 
    add_column :groups, :content_auth, :boolean,:default => false
  end

  def self.down
    remove_column :groups, :content_auth
    remove_column :groups, :member_auth
  end
end
