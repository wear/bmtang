require 'coderay'
require 'coderay/helpers/file_type'
require 'forwardable'
require 'cgi'

module ApplicationHelper 
  include WikiFormatting::Macros::Definitions
#  include GravatarHelper::PublicMethods     

  extend Forwardable
	
	def group_icon_for(group,size)
    if group.icon_exists?
      link_to image_tag(group.asset.public_filename(size.to_sym)),group
    else  
      link_to image_tag('/images/unknow-group.gif',:size => calc_size(size)),group
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
  
  protected
  
  def calc_size(size) 
    case size
    when 'large'
      '64x64'
    else
      '48x48'
    end
  end
end
