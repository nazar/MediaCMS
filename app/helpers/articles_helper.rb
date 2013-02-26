module ArticlesHelper
  
  #returns next, previos revision links for a given article and revision
  def revision_navigation(article, revision)
    links = []
    links << link_to_remote('previous', :url => {:action => :previous_revision, :id => article.id, :rev => revision}) if revision > 1
    links << link_to_remote('next', :url => {:action => :next_revision, :id => article.id, :rev => revision}) if (revision < article.article_revisions.last.revision)
    #construct and return
    links.join(' | ')
  end
  
  #returns a comma seperated link of tags for a given article
  def article_tags(article)
    tags = article.tags.collect{|tag| link_to tag.name, :controller => 'tags', :action => :articles, :id => tag.name}
    tags = tags.join('  ')
  end
  
end
