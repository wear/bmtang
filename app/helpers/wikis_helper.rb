module WikisHelper
  
  def preview_content(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    case args.size
    when 1
      obj = options[:object]
      text = args.shift
    when 2
      obj = args.shift
      text = obj.send(args.shift).to_s
    else
      raise ArgumentError, 'invalid arguments to textilizable'
    end
     return '' if text.blank?
    obj.text 
        
  end 

  # Formats text according to system settings.
  # 2 ways to call this method:
  # * with a String: textilizable(text, options)
  # * with an object and one of its attribute: textilizable(issue, :description, options)
  def textilizable(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    case args.size
    when 1
      obj = options[:object]
      text = args.shift
    when 2
      obj = args.shift
      text = obj.send(args.shift).to_s
    else
      raise ArgumentError, 'invalid arguments to textilizable'
    end
    return '' if text.blank?

    only_path = options.delete(:only_path) == false ? false : true

    # when using an image link, try to use an attachment, if possible
    attachments = options[:attachments] || (obj && obj.respond_to?(:attachments) ? obj.attachments : nil)

    if attachments
      attachments = attachments.sort_by(&:created_on).reverse
      text = text.gsub(/!((\<|\=|\>)?(\([^\)]+\))?(\[[^\]]+\])?(\{[^\}]+\})?)(\S+\.(bmp|gif|jpg|jpeg|png))!/i) do |m|
        style = $1
        filename = $6.downcase
        # search for the picture in attachments
        if found = attachments.detect { |att| att.filename.downcase == filename }
          image_url = url_for :only_path => only_path, :controller => 'attachments', :action => 'download', :id => found
          desc = found.description.to_s.gsub(/^([^\(\)]*).*$/, "\\1")
          alt = desc.blank? ? nil : "(#{desc})"
          "!#{style}#{image_url}#{alt}!"
        else
          m
        end
      end
    end

    text = WikiFormatting.to_html(AppConfig.text_formatting, text) { |macro, args| exec_macro(macro, obj, args) }

    # different methods for formatting wiki links
    case options[:wiki_links]
    when :local
      # used for local links to html files
      format_wiki_link = Proc.new {|group, title, anchor| "#{title}.html" }
    when :anchor
      # used for single-file wiki export
      format_wiki_link = Proc.new {|group, title, anchor| "##{title}" }
    else
      format_wiki_link = Proc.new {|group, title, anchor| url_for(:only_path => only_path, :controller => 'wikis', :action => 'page', :group_id => group, :page => title, :anchor => anchor) }
    end

    group = options[:group] || @group || (obj && obj.respond_to?(:group) ? obj.group : nil)

    # Wiki links
    #
    # Examples:
    #   [[mypage]]
    #   [[mypage|mytext]]
    # wiki links can refer other group wikis, using group name or identifier:
    #   [[group:]] -> wiki starting page
    #   [[group:|mytext]]
    #   [[group:mypage]]
    #   [[group:mypage|mytext]]
    text = text.gsub(/(!)?(\[\[([^\]\n\|]+)(\|([^\]\n\|]+))?\]\])/) do |m|
      link_group = group
      esc, all, page, title = $1, $2, $3, $5
      if esc.nil?
        if page =~ /^([^\:]+)\:(.*)$/
          link_group = Group.find_by_name($1) || Group.find_by_identifier($1)
          page = $2
          title ||= $1 if page.blank?
        end

        if link_group && link_group.wiki
          # extract anchor
          anchor = nil
          if page =~ /^(.+?)\#(.+)$/
            page, anchor = $1, $2
          end
          # check if page exists
          wiki_page = link_group.wiki.find_page(page)
          link_to((title || page), format_wiki_link.call(link_group, Wiki.titleize(page), anchor),
                                   :class => ('wiki-page' + (wiki_page ? '' : ' new')))
        else
          # group or wiki doesn't exist
          all
        end
      else
        all
      end
    end

    # Redmine links
    #
    # Examples:
    #   Issues:
    #     #52 -> Link to issue #52
    #   Changesets:
    #     r52 -> Link to revision 52
    #     commit:a85130f -> Link to scmid starting with a85130f
    #   Documents:
    #     document#17 -> Link to document with id 17
    #     document:Greetings -> Link to the document with title "Greetings"
    #     document:"Some document" -> Link to the document with title "Some document"
    #   Versions:
    #     version#3 -> Link to version with id 3
    #     version:1.0.0 -> Link to version named "1.0.0"
    #     version:"1.0 beta 2" -> Link to version named "1.0 beta 2"
    #   Attachments:
    #     attachment:file.zip -> Link to the attachment of the current object named file.zip
    #   Source files:
    #     source:some/file -> Link to the file located at /some/file in the group's repository
    #     source:some/file@52 -> Link to the file's revision 52
    #     source:some/file#L120 -> Link to line 120 of the file
    #     source:some/file@52#L120 -> Link to line 120 of the file's revision 52
    #     export:some/file -> Force the download of the file
    #  Forum messages:
    #     message#1218 -> Link to message with id 1218
    text = text.gsub(%r{([\s\(,\-\>]|^)(!)?(attachment|document|version|commit|source|export|message)?((#|r)(\d+)|(:)([^"\s<>][^\s<>]*?|"[^"]+?"))(?=(?=[[:punct:]]\W)|\s|<|$)}) do |m|
      leading, esc, prefix, sep, oid = $1, $2, $3, $5 || $7, $6 || $8
      link = nil
      if esc.nil?
        if prefix.nil? && sep == 'r'
          if group && (changeset = group.changesets.find_by_revision(oid))
            link = link_to("r#{oid}", {:only_path => only_path, :controller => 'repositories', :action => 'revision', :id => group, :rev => oid},
                                      :class => 'changeset',
                                      :title => truncate_single_line(changeset.comments, :length => 100))
          end
        elsif sep == '#'
          oid = oid.to_i
          case prefix
          when nil
            if issue = Issue.find_by_id(oid, :include => [:group, :status], :conditions => group.visible_by(User.current))
              link = link_to("##{oid}", {:only_path => only_path, :controller => 'issues', :action => 'show', :id => oid},
                                        :class => (issue.closed? ? 'issue closed' : 'issue'),
                                        :title => "#{truncate(issue.subject, :length => 100)} (#{issue.status.name})")
              link = content_tag('del', link) if issue.closed?
            end
          when 'document'
            if document = Document.find_by_id(oid, :include => [:group], :conditions => group.visible_by(User.current))
              link = link_to h(document.title), {:only_path => only_path, :controller => 'documents', :action => 'show', :id => document},
                                                :class => 'document'
            end
          when 'version'
            if version = Version.find_by_id(oid, :include => [:group], :conditions => group.visible_by(User.current))
              link = link_to h(version.name), {:only_path => only_path, :controller => 'versions', :action => 'show', :id => version},
                                              :class => 'version'
            end
          when 'message'
            if message = Message.find_by_id(oid, :include => [:parent, {:board => :group}], :conditions => group.visible_by(User.current))
              link = link_to h(truncate(message.subject, :length => 60)), {:only_path => only_path,
                                                                :controller => 'messages',
                                                                :action => 'show',
                                                                :board_id => message.board,
                                                                :id => message.root,
                                                                :anchor => (message.parent ? "message-#{message.id}" : nil)},
                                                 :class => 'message'
            end
          end
        elsif sep == ':'
          # removes the double quotes if any
          name = oid.gsub(%r{^"(.*)"$}, "\\1")
          case prefix
          when 'document'
            if group && document = group.documents.find_by_title(name)
              link = link_to h(document.title), {:only_path => only_path, :controller => 'documents', :action => 'show', :id => document},
                                                :class => 'document'
            end
          when 'version'
            if group && version = group.versions.find_by_name(name)
              link = link_to h(version.name), {:only_path => only_path, :controller => 'versions', :action => 'show', :id => version},
                                              :class => 'version'
            end
          when 'commit'
            if group && (changeset = group.changesets.find(:first, :conditions => ["scmid LIKE ?", "#{name}%"]))
              link = link_to h("#{name}"), {:only_path => only_path, :controller => 'repositories', :action => 'revision', :id => group, :rev => changeset.revision},
                                           :class => 'changeset',
                                           :title => truncate_single_line(changeset.comments, :length => 100)
            end
          when 'source', 'export'
            if group && group.repository
              name =~ %r{^[/\\]*(.*?)(@([0-9a-f]+))?(#(L\d+))?$}
              path, rev, anchor = $1, $3, $5
              link = link_to h("#{prefix}:#{name}"), {:controller => 'repositories', :action => 'entry', :id => group,
                                                      :path => to_path_param(path),
                                                      :rev => rev,
                                                      :anchor => anchor,
                                                      :format => (prefix == 'export' ? 'raw' : nil)},
                                                     :class => (prefix == 'export' ? 'source download' : 'source')
            end
          when 'attachment'
            if attachments && attachment = attachments.detect {|a| a.filename == name }
              link = link_to h(attachment.filename), {:only_path => only_path, :controller => 'attachments', :action => 'download', :id => attachment},
                                                     :class => 'attachment'
            end
          end
        end
      end
      leading + (link || "#{prefix}#{sep}#{oid}")
    end

    text
  end 
  
  def accesskey(s)
    AccessKeys.key_for s
  end  
  
  # Same as Rails' simple_format helper without using paragraphs
  def simple_format_without_paragraph(text)
    text.to_s.
      gsub(/\r\n?/, "\n").                    # \r\n and \r -> \n
      gsub(/\n\n+/, "<br /><br />").          # 2+ newline  -> 2 br
      gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')  # 1 newline   -> br
  end
  
  def html_diff(wdiff)
    words = wdiff.words.collect{|word| h(word)}
    words_add = 0
    words_del = 0
    dels = 0
    del_off = 0
    wdiff.diff.diffs.each do |diff|
      add_at = nil
      add_to = nil
      del_at = nil
      deleted = ""	    
      diff.each do |change|
        pos = change[1]
        if change[0] == "+"
          add_at = pos + dels unless add_at
          add_to = pos + dels
          words_add += 1
        else
          del_at = pos unless del_at
          deleted << ' ' + change[2]
          words_del	 += 1
        end
      end
      if add_at
        words[add_at] = '<span class="diff_in">' + words[add_at]
        words[add_to] = words[add_to] + '</span>'
      end
      if del_at
        words.insert del_at - del_off + dels + words_add, '<span class="diff_out">' + deleted + '</span>'
        dels += 1
        del_off += words_del
        words_del = 0
      end
    end
    simple_format_without_paragraph(words.join(' '))
  end
  
  # Return true if user is authorized for wiki, otherwise false
  def authorize_for(group)
    current_user.becomes(LearnUser).allowed_to?(group)
  end

  # Display a link if user is authorized
  def link_to_if_authorized(group,name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options, html_options, *parameters_for_method_reference) if authorize_for(group)
  end

  # Display a link to remote if user is authorized
  def link_to_remote_if_authorized(name, options = {}, html_options = nil)
    url = options[:url] || {}
    link_to_remote(name, options, html_options) if authorize_for(url[:controller] || params[:controller], url[:action])
  end
  
  def labelled_tabular_form_for(name, object, options, &proc)
    options[:html] ||= {}
    options[:html][:class] = 'tabular' unless options[:html].has_key?(:class)
    form_for(name, object, options.merge({ :builder => TabularFormBuilder, :lang => 'zh'}), &proc)
  end    
  
  def pagination_links_full(paginator, count=nil, options={})
    page_param = options.delete(:page_param) || :page
    url_param = params.dup
    # don't reuse query params if filters are present
    url_param.merge!(:fields => nil, :values => nil, :operators => nil) if url_param.delete(:set_filter)

    html = ''
    if paginator.current.previous
      html << link_to_remote_content_update('&#171; ' + l(:label_previous), url_param.merge(page_param => paginator.current.previous)) + ' '
    end

    html << (pagination_links_each(paginator, options) do |n|
      link_to_remote_content_update(n.to_s, url_param.merge(page_param => n))
    end || '')
    
    if paginator.current.next
      html << ' ' + link_to_remote_content_update((l(:label_next) + ' &#187;'), url_param.merge(page_param => paginator.current.next))
    end

    unless count.nil?
      html << [
        " (#{paginator.current.first_item}-#{paginator.current.last_item}/#{count})",
        per_page_links(paginator.items_per_page)
      ].compact.join(' | ')
    end

    html
  end
  
  def per_page_links(selected=nil)
    url_param = params.dup
    url_param.clear if url_param.has_key?(:set_filter)                                                            
    
    per_page_options_array = AppConfig.per_page_options.split(%r{[\s,]}).collect(&:to_i).select {|n| n > 0}.sort  
    links = per_page_options_array.collect do |n|
      n == selected ? n : link_to_remote(n, {:update => "content",
                                             :url => params.dup.merge(:per_page => n),
                                             :method => :get},
                                            {:href => url_for(url_param.merge(:per_page => n))})
    end
    links.size > 1 ? :label_display_per_page.l : nil
  end   
  
  def render_page_hierarchy(pages, node=nil)
    content = ''
    if pages[node]
      content << "<ul class=\"pages-hierarchy\">\n"
      pages[node].each do |page|
        content << "<li>"
        content << link_to(h(page.pretty_title), {:controller => 'wikis', :action => 'page', :id => page.group, :page => page.title},
                           :title => (page.respond_to?(:updated_on) ? (:label_updated_time.l + distance_of_time_in_words(Time.now, page.updated_on)) : nil))
        content << "\n" + render_page_hierarchy(pages, page.id) if pages[page.id]
        content << "</li>\n"
      end
      content << "</ul>\n"
    end
    content
  end    
  
  def breadcrumb(*args)
    elements = args.flatten
    elements.any? ? content_tag('p', args.join(' &#187; ') + ' &#187; ', :class => 'breadcrumb') : nil
  end
  
end
