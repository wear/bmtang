class LearnUser < User 
  
  include_simple_groups
  has_many :memberships,:foreign_key => 'user_id'     
  has_many :bookmarks,:foreign_key => 'user_id'         
  
  def allowed_to?(group)
    is_member_of?(group) 
  end
  
  def request_membership_of(group)
    group.pending_members << self unless self.is_member_of?(group)
  end
  
  def become_admin_of(group)
      group.members << self unless self.pending_and_accepted_groups.include?(group)
      group.accept_member(self)
      group.set_mod(self)
  end
  
end