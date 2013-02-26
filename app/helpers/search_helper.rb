module SearchHelper

  def render_media_search_result(results)
    render_medias_block(results, 'search')
  end

  def search_options_select
    select_tag 'search_type',
               options_for_select(Search.search_types.sort{|a,b| a[0]<=>b[0]}.collect{|a| [a.last, a.first]}, params[:search_type].to_i)
  end

  def category_title(category)
    content_tag(:div, :class => 'block_title') do
      content_tag(:h3) do
        "Found Category #{link_to(category.name, category_id_path(category.id))} - " <<
        "Found #{pluralize(category.medias.count, 'media')} - " <<
        "#{link_to('View all', category_id_path(category.id))}"
      end
    end
  end

  def user_title(user)
    content_tag(:div, :class => 'block_title') do
      content_tag(:h3) do
        "Found Member #{link_to(user.name, user_about_path(user.login))} " <<
        "with #{pluralize(user.medias.count, 'media')} - " <<
        "#{link_to('View all', user_photos_path(user.login))}"
      end
    end
  end

end
