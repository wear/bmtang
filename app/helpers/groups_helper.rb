module GroupsHelper
  def group_admin?(admin_role)
    admin_role ? '管理员' : '成员'
  end

end
