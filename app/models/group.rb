class Group < ActiveRecord::Base 
  acts_as_taggable
  has_one :asset, :as => 'attachable' 
  has_one :wiki, :dependent => :destroy
  validates_length_of :title, :within => 3..20, :message => "必须大于三个字符" 
  validates_length_of :description, :within => 10..200, :on => :create, :message => "10到200个字符"
  has_many :posts
  has_many :comments, :through => :posts
  has_many :memberships
  has_many :members, :through => :memberships, :source => :user, :conditions => 'accepted_at IS NOT NULL'
  has_many :pending_members, :through => :memberships, :source => :user,:conditions => 'accepted_at IS NULL'
  has_many :mods, :through => :memberships, :source => :user, :conditions => ['admin_role = ?', true]
  after_save :create_initial_wiki
  has_many :bookmarks 
  
  def recent_activity(page = {}, options = {})
    page.reverse_merge! :size => 10, :current => 1
    case options[:type]
    when 'all'
      Activity.recent.find(:all,:conditions => ['group_id = ?',self.id], :page => page)      
    when 'wiki'
      Activity.recent.find(:all,:conditions => ['group_id = ? and action = ?',self.id,"wiki_content/version"], :page => page)
    when '讨论区'
      Activity.recent.find(:all,:conditions => ['group_id = ? and action = ?',self.id,"post"], :page => page) 
    end
  end
  
  def membership(user)
    Membership.find(:first, :conditions => ['group_id = ? AND user_id = ?', self.id, user.id])
  end
  
  def accept_member(user)
    self.membership(user).update_attribute(:accepted_at, Time.now)
    Activity.create(:user => user,:group => self,:action => 'accept_member')
  end 
  
  def created_by?(user)
    created_by == user.id
  end
  
  def pending_and_accepted_members
    self.pending_members + self.members
  end
  
  def kick(user)
    self.membership(user).destroy if user.is_member_of?(self)
    self.create_activity_from_self(post.group)
    Activity.create(:user => user,:group => self,:action => 'kick_member') 
  end
  
  def recent_members
    self.members.find(:all,:order => 'accepted_at DESC',:limit => 2)
  end
  
  def set_mod(user)
    self.membership(user).update_attribute(:admin_role, true)
    Activity.create(:user => user,:group => self,:action => 'set_mod')
  end
  
  def mods_online
    self.mods.find(:all, :conditions => ['users.updated_at > ?', 50.seconds.ago])
  end
  
  def members_online
    self.members.find(:all, :conditions => ['users.updated_at > ?', 70.seconds.ago])
  end
  
  def members_offline
    self.members - self.members_online
  end
  
  def has_member?(user)
    self.members.include?(user) || self.created_by == user.id
  end
  
  def post_count(category)
    Post.count(:conditions => ['category_id =? and group_id =?',category,self])
  end
  
  def icon_exists?
    return false unless asset
    File.file? "public/#{asset.public_filename}"
  end
  
  def icon_data=(data)
    return if data.blank? 
    if asset
      asset.update_attributes :uploaded_data => data
    else
      self.asset = Asset.create :uploaded_data => data
    end
  end 
  
  def create_initial_wiki
    if self.wiki.nil?
      Wiki.create(:group => self, :start_page => 'Wiki')
    end
  end
end
