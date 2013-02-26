class ArticleCategory < ActiveRecord::Base
  has_many :articles
  has_many :approved_articles, :class_name => 'Article', :order => 'articles.title',
           :conditions => 'articles.approved = 1'  
  
end
