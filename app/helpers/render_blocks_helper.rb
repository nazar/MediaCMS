module RenderBlocksHelper
  
  def render_block(title, body)
    render :file => 'layouts/_block', 
           :use_full_path => true, 
           :locals => { :title => title, :body  => body }
  end
  
  #left blocks
  
  def render_javascript
    render_block('Javascript', 
                 'This website requires Javascript support. Please enable javascript support in your browser.')
  end
      
  def render_collapse_category_tree(tree, parent_id = nil, level = 0, options = {})
    level += 2
    body = ''
    top_indicator_open  = options[:indicator] ? '[+]' : ''
    top_indicator_close = options[:indicator] ? '[-]' : ''
    sub_inidcator       = options[:indicator] ? 'L ' : ''
    #
    tree.each do |node|
      if node.parent_id == parent_id
        if node.children.count > 0
          url = category_name_url(:id => node.id, :name => node.name.to_permalink)
          body << "<div class='main' style='padding-left:#{level}px'><strong><a href=\"javascript:toggle('#{node.id}','#{top_indicator_open}','#{top_indicator_close}');\">"
          body << "<span id='m#{node.id}'>#{top_indicator_open}</span></a><a href='#{url}'>#{h(node.name)} (#{node.members_count})</a></strong><br /></div>"
          body << "<div id='s#{node.id}' class='closed' style='padding-bottom: 2px;'>"
          body << render_collapse_category_tree(tree, node.id, level, options)
          body << '</div>'
        else
          url = category_name_path(:id => node.id, :name => node.name.to_permalink)
          body << "<div class='sub'style='padding-left:#{level}px'>&nbsp;&nbsp;#{sub_inidcator}<a href='#{url}'>#{h(node.name)} (#{node.members_count})</a></div>"
        end
      end
    end
    body += ''
  end 
  
  def render_collapse_category_block(options = {})
    options[:indicator] = options[:indicator] === false ? false : true
    #
    body = '<div class="menu category">'
    body << render_collapse_category_tree(Category.all, nil, 0, options)
    body << '</div>'
    #
    render_block('Categories', body)
  end
   
  def render_top_categories_block(limit = 15)
    body = '' 
    Category.top_categories(:limit => limit) do |c|
      url = category_name_path(:id => c.id, :name => c.name)
      body << "<div class='category'><a href='#{url}'> #{h(c.name)} (#{c.members_count})</a></div>"
    end
    render_block('Top Categories', body)
  end
  
  def render_top_tags_block(limit = 15)
    body = '';
    Tag.top_tags(:limit => limit).each do |t|
      body << "<div class='category'><a href='/tags/show/#{h t.name}'> #{h t.name} (#{t.taggings_count})</a></div>"
    end
    render_block('Top Tags',body)
  end
  
  def render_misc_block
    body = content_tag(:div, link_to('Links', :controller => 'links'), :class => 'category')
    render_block('Misc', body)
  end
  
  def render_top_photographers_block(limit = 10)
    body = '';
    User.top_authors(:limit => limit) do |t|
      body += "<div class='category'><a href='/account/about/#{h t.login.gsub(' ','%20')}'>#{h t.login} (#{t.photos_count})</a></div>"
    end
    render_block('Most Photos',body) if body != ''
  end 
  
  def render_top_selling_block(limit = 10)
    body = '';
    Photo.best_selling(:limit => limit) do |t|
      name = t.title.length > 19 ? t.title[0..19]+'...' : t.title
      link = link_to(h(name), photo_view_path(t.id, t.title.to_permalink))
      body += "<div class='category'>#{link}</div>"
    end
    render_block('Best Selling',body) if body != ''
  end
  
  def render_best_photographers_block(limit = 10)
    body = ''
    User.best_authors(:limit => limit) do |t|
      body += "<div class='category'><a href='/account/about/#{h t.login.gsub(' ','%20')}'>#{h t.login} (#{t.photos_count})</a></div>"
    end
    render_block('Best Rated',body) if body != ''
  end 
  
  def render_most_blogged_users_block(limit = 10)
    body = ''
    User.most_blogged(:limit => limit) do |t|  
      body += "<div class='category'><a href='/blogs/by/#{h t.login.gsub(' ','%20')}'>#{h t.login} (#{t.blogs_count})</a></div>"
    end
    render_block('Most Blogs',body) if body != ''
  end
  
  def render_busiest_forums_block(limit = 10)
    body = ''
    Forum.busiest_forums(:limit => limit) do |f|
      body += "<div class='category'><a href='#{forum_url(:id=>f.id)}'>#{h f.name} (#{f.posts_count})</a></div>"
    end
    render_block('Busiest Forums',body) if body != ''
  end
  
  def render_best_viewed
    body = render :partial => '/layouts/best_viewed'
    render_block('Best With', body)
  end
  
  #center block
  
  def render_search_box
    body = render :partial => '/photos/search_box'
    render :partial => '/layouts/rounded_block', :locals => {:content => body}
  end
  
  def rss_photo_block(photo)
    render :partial => '/photos/rss_picture',
                   :locals => {:photo => photo}
  end
  
  def render_center_block(title, block)
    page = ''
    unless block.blank?
      page << "<div class=\"block_title\"><h2>#{title}</h2></div>"
      page << "<div class='step'>#{block}<br clear='all'/></div>"
    end
    page
  end

  def render_recent_collections
    body = ''
    for collection in Collection.latest_collections(6)
      body << (render :partial => 'collections/collection_snapshot',
                     :locals => {:collection => collection} if collection.collections_items.length > 0)
    end
    body
  end
  
  def render_last_blog
    blogs  = Blog.get_blogs_order_date(2)
    result = '' 
    for blog in blogs do
      result += render :partial => '/blogs/blog_summary', :locals => {:blog => blog}
    end
    return result
  end
  
  def render_popular_links(limit=20)
    links = Link.popular_links(limit, current_user)
    render :partial => 'links/links_list', :locals => {:links => links}
  end
  
  def render_recent_forum_topics
    render :partial => 'forums/topics_table', :locals => {:topics => Topic.latest_topics(7)}
  end

  def render_recent_comments
    header = render :partial => '/comments/comments_table_header'
    body   = ''
    count = 1
    Comment.latest_comments(:limit => 10) do |c|
      body += render :partial => '/comments/comments_table_row',
                     :locals  => {:comment => c, :count => count}
      count += 1 
    end
    if body
      return header + body + '</tbody></table>'
    else
      return ''
    end
  end
  
  def random_select(objs, count)
    target = objs.length > count ? count : objs.length
    pot = []
    result = []
    objs.each {|o| pot << o}
    srand
    #
    target.times { |i|
      idx = rand(pot.length)
      result << pot.at(idx)
      pot.delete_at(idx)
    }
    return result
  end

  def render_title_link_block(title, body, options={})
    options[:block_class]  ||= 'block_title'
    options[:feed_class]   ||= 'feed'
    options[:view_more]    ||= 'view more'
    options[:body_class]   ||= 'step'
    options[:more_class]   ||= 'more'
    #
    unless body.blank?
      markaby do
        div :class => options[:block_class] do
          unless options[:feed_action].blank?
            div :class => options[:feed_class] do
              link_to(image_tag('rss.gif'), {:controller => 'feed', :action => options[:feed_action]},{:class => 'no_underline'})
            end
          end
          h2 title
          span :class => options[:more_class] do
            ' - ' << link_to(options[:view_more], options[:more_link]) unless options[:more_link].blank?
          end
        end
        div :class => options[:body_class] do
          body
        end
      end
    end
  end
  
    
end
