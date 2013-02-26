module ActionView::Helpers::AssetTagHelper

  def render_tag_cloud(tags, min, max, classes, options={})
    raise "block not given" unless block_given?
    raise "class is not an array. Received #{classes.class.to_s}" unless classes.is_a? Array
    #
    divisor = ((max - min) / classes.size) + 1
    #
    tags.each do |t|
      yield t, classes[((t.taggings_count.to_i - min) / divisor).round]
    end
  end

  def object_tag_cloud(object, classes, options={}, &block)
    raise "block not given" unless block_given?
    raise "class is not an array. Received #{classes.class.to_s}" unless classes.is_a? Array
    #
    tags, min, max = object.top_tags(options[:limit])   
    render_tag_cloud(tags, min, max, classes, options, &block)
  end

end