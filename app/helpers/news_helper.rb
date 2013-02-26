module NewsHelper

  def news_title(newsable, link = true)
    if newsable.itemable_type == 'Club'
      if link
        link_to newsable.title, polymorphic_path(newsable.itemable)
      else
        newsable.title
      end  
    else
      newsable.title
    end
  end

end