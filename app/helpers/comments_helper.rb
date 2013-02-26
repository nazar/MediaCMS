module CommentsHelper

  def comment_to_controller(comment)
    anchor = "comment-#{comment.id}"
    case
      when comment.commentable_type == 'Article'; return article_view_link_path(comment.commentable_id, :anchor => anchor)
      when comment.commentable_type == 'Blog';  return blog_view_link_path(comment.commentable_id, :anchor => anchor)
      when comment.commentable_type == 'Collection'; return collection_view_link_path(comment.commentable_id, :anchor => anchor)
      when comment.commentable_type == 'NewsItem'; return newsitem_view_link_path(comment.commentable_id, :anchor => anchor)
      when comment.commentable_type == 'RssFeedItem'; return rssfeeditem_view_link_path(comment.commentable_id, :anchor => anchor)
      when comment.commentable_type == 'Media';
        if comment.commentable.class.name == 'Photo'
          return photo_view_link_path(comment.commentable_id, :anchor => anchor)
        elsif comment.commentable.class.name == 'Video'
          return video_view_link_path(comment.commentable_id, :anchor => anchor)
        elsif comment.commentable.class.name == 'Audio'
          return audio_view_link_path(comment.commentable_id, :anchor => anchor)
        end
      when 'Link'; return link_view_link_path(comment.commentable_id, :anchor => anchor)
    end  
  end

  def comment_to_area(comment)
    comment.commentable_type.pluralize
  end

  def comment_owner_class(comment, css_class = 'owner')
    if comment.commentable.respond_to?('user_id')
      comment.user_id == comment.commentable.user_id ? css_class : ''
    else
      ''
    end  
  end

  def display_anon_user(comment)
    if not comment.anon_name.blank?
      if not comment.anon_url.blank?
        link_to comment.anon_name, comment.anon_url, {:target => '_blank'}
      else
        h(comment.anon_name)
      end
    else
      'anonymous'
    end
  end
  
end
