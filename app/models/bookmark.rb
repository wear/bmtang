class Bookmark < ActiveRecord::Base 
  belongs_to :user, :class_name => "Use", :foreign_key => "use_id" 
  belongs_to :group
  belongs_to :wiki_page
  acts_as_taggable 
  validates_length_of :content, :within => 3..200, :message => "在两百字符已内"
  
  acts_as_activity  :user, :group => Proc.new{|r| r.group }  
  
end
