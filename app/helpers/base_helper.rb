require 'md5'

# Methods added to this helper will be available to all templates in the application.
module BaseHelper
  def page_title
  	app_base = AppConfig.community_name
		tagline = " | #{AppConfig.community_tagline}"    
  
  	title = app_base
  	case @controller.controller_name
  	  when 'landing'
        title = '首页'+' &raquo; ' + app_base + tagline
  		when 'base'
  			case @controller.action_name
  				when 'popular'
  					title = :popular_posts.l+' &raquo; ' + app_base + tagline
  				else 
  					title += tagline
  			end
  		when 'groups'
  			case @controller.action_name
  				when 'activity'
  					title = :activity.l + ' &raquo; ' + app_base + tagline
  				else 
  					title = @group.title + ' &raquo; ' + app_base + tagline
  			 end
  		when 'wikis'   
  					title = @group.title + :wiki.l + ' &raquo; ' + app_base + tagline
  		when 'posts'
        if @post and @post.title        
          title = @post.title + ' &raquo; ' + app_base + tagline
          title += (@post.tags.empty? ? '' : " &laquo; "+:keywords.l+": " + @post.tags[0...4].join(', ') )
        end
  		when 'users'
        if @user and @user.login
          title = @user.login
          title += ', expert in ' + @user.offerings.collect{|o| o.skill.name }.join(', ') if @user.vendor? and !@user.offerings.empty?
          title += ' &raquo; ' + app_base + tagline
        else
          title = :showing_users.l+' &raquo; ' + app_base + tagline
        end
  		when 'photos'
        if @user and @user.login
          title = @user.login + '\'s '+:photos.l+' &raquo; ' + app_base + tagline
        end
  		when 'clippings'
        if @user and @user.login
          title = @user.login + '\'s '+:clippings.l+' &raquo; ' + app_base + tagline
        end
  		when 'tags'
        if @tag and @tag.name
          title = @tag.name + ' '+:posts_photos_and_bookmarks.l+' &raquo; ' + app_base + tagline
          title += ' | Related: ' + @related_tags.join(', ')
        else
          title = 'Showing tags &raquo; ' + app_base + tagline
        end
      when 'categories'
        if @category and @category.name
          title = @category.name + ' '+:posts_photos_and_bookmarks.l+' &raquo; ' + app_base + tagline
        else
          title = :showing_categories.l+' &raquo; ' + app_base + tagline            
        end
      when 'skills'
        if @skill and @skill.name
          title = :find_an_expert_in.l+' ' + @skill.name + ' &raquo; ' + app_base + tagline
        else
          title = :find_experts.l+' &raquo; ' + app_base + tagline            
        end
      when 'sessions'
        title = :login.l+' &raquo; ' + app_base + tagline            
  	end
  
    if @page_title
      title = @page_title + ' &raquo; ' + app_base + tagline
    elsif title == app_base          
  	  title = :showing.l+' ' + @controller.controller_name + ' &raquo; ' + app_base + tagline
    end	
  	title
  end    
  
  def other_formats_links(&block)
    concat('<p class="other-formats">' + :label_export_to.l)
    yield Views::OtherFormatsBuilder.new(self)
    concat('</p>')
  end
  
end
