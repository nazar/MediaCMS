module ForumsHelper
  
  # used to know if a topic has changed since we read it last
  def recent_topic_activity(topic)
    return false if not logged_in?
    return topic.replied_at > (session[:topics][topic.id] || last_active)
  end 
  
  # used to know if a forum has changed since we read it last
  def recent_forum_activity(forum)
    return false unless logged_in? && forum.topics.first
    return forum.topics.first.replied_at > (session[:forums][forum.id] || last_active)
  end
  
  def markup_post_text(post, options = {}, html_options = {}) #TODO is this used?
    #the editor is only displayed if this is the admin or owner of post and posted in last 60 minutes
    if can_edit_post(post)
      editor      = content_tag('div','',{:id => "#{post.id}_editor_placeholder", :style => 'display:none'})
    else
      editor     = ''
    end

    viewer_opts = {:id => "#{post.id}_viewer", :class => 'comText'}
    viewer      = content_tag('div', Misc.format_red_cloth(post.body), viewer_opts)
    
    return editor + viewer;
  end
  
  def can_edit_post(post_obj)
    current_user && (current_user.admin || ((current_user.id == post_obj.user_id) && (post_obj.created_at + 60.minute > Time.now) ) ) #TODO 60 mins in Configuration
  end  
  
  def markup_post_edit(post, options = {}, html_options = {}) #TODO replace with markup helper
    @post = post
    def hide_editor_script
      "Element.update('#{@post.id}_editor_placeholder','');"+
      "Element.hide('#{@post.id}_editor_placeholder');"+
      "Element.show('#{@post.id}_viewer'); return false;"
    end
    def get_preview_link(controller)
      pl_options = {}
      pl_options[:url]      = {:controller => controller, :action => "preview_post", :id => @post.id} 
      pl_options[:with]     = "Form.serializeElements([$('#{@post.id}_editor')])" 
      pl_options[:complete] = "Element.hide('#{@post.id}_editor'); Element.hide('markup-area-link'); "+
                              "Element.show('#{@post.id}_preview'); Element.show('markup-area-link-preview');"
      return link_to_remote('preview post',pl_options)
    end
    def get_save_link(controller)
      ed_options = {}
      ed_options[:url]      = {:controller => controller, :action => "save_post", :id => @post.id} 
      ed_options[:with]     = "Form.serializeElements([$('#{@post.id}_editor')])"
      
      return link_to_remote('save post',ed_options)
    end
    controller = post.class == Comment ? 'comments' : 'forums'
    #preview
    preview_link     = get_preview_link(controller)
    #editor links
    markup_help_link =  link_to('textile markup reference', "#{ActionController::Base.asset_host}/textile_reference.html", 
                    :popup => ['textile markup reference', 
                       'height=400,width=520,location=0,status=0,menubar=0,resizable=1,scrollbars=1'])
    cancel_link      = link_to_function('cancel edit', hide_editor_script)
    save_link        = get_save_link(controller)
    links            = content_tag('div', markup_help_link + ' | ' + preview_link + ' | ' + save_link  + ' | ' + cancel_link, 
                      {:id => 'markup-area-link', :class => 'markup-area-link'})
     
    editor  = text_area_tag("#{post.id}_editor", post.body, html_options.merge!({:class => 'markup-editor'})) + links
    #markup preview placeholder
    link_function = "Element.hide('#{post.id}_preview'); Element.show('#{post.id}_editor');"+
                    "Element.hide('markup-area-link-preview'); Element.show('markup-area-link');"
    close_preview_link = content_tag('div', 
                                     link_to_function('Close preview', link_function), 
                                     {:id => 'markup-area-link-preview', :class => 'markup-area-link', :style => 'display: none;'})
    #render hidden preview                                  
    preview = content_tag('div','',{:id => "#{post.id}_preview", :class => 'markup-preview', :style => 'display: none; '}) +
              close_preview_link
    
    return editor + preview
  end
  
  # inplace editing ajax stuff
  def edit_post_ajax(page, comment) #TODO replace with markup helper
    if can_edit_post(comment)
      page.hide("#{comment.id}_viewer")
      page.show("#{comment.id}_editor_placeholder")
      page.replace_html("#{comment.id}_editor_placeholder", markup_post_edit(comment))
    end
  end
  
  def preview_post_ajax(page, comment, edit_text) #TODO replace with markup helper
    if can_edit_post(comment)
      page.replace_html("#{comment.id}_preview", Misc.format_red_cloth(edit_text))
    end
  end

  def save_post_ajax(page, comment, edit_text) #TODO replace with markup helper
    if can_edit_post(comment)
      comment.body = edit_text;
      comment.save
      #update
      page.hide("#{comment.id}_editor_placeholder")
      page.replace_html("#{comment.id}_editor_placeholder",'')
      
      page.show("#{comment.id}_viewer")
      page.replace_html("#{comment.id}_viewer", markup_post_text(comment)) 
    end
  end
  
end
