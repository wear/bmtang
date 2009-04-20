require 'coderay'
require 'coderay/helpers/file_type'
require 'forwardable'
require 'cgi'

module ApplicationHelper 
  include WikiFormatting::Macros::Definitions
#  include GravatarHelper::PublicMethods     

  extend Forwardable
	
	def group_icon_for(group)
    if group.icon_exists?
      image_tag group.asset.public_filename(:thumb)
    else
      image_tag('/images/icon/icon_missing_thumb.gif')
    end
  end 
  
  def html_title(*args)
    if args.empty?
      title = []
      title << @group.name if @group
      title += @html_title if @html_title
      title << AppConfig.community_name
      title.compact.join(' - ')
    else
      @html_title ||= []
      @html_title += args
    end
  end
  
end
