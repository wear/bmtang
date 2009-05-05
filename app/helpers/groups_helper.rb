module GroupsHelper
  def group_admin?(admin_role)
    admin_role ? '管理员' : '成员'
  end
  
  def show_description(group)
    group.description ? '暂无介绍' : h(group.description)
  end

end
