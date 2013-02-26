class Admin::ArticleCategoriesController < Admin::BaseController
  
  active_scaffold :article_category do |config|
    config.label = "Article Categories"
    #override to set display order
    config.columns   = [:name, :description]
  end  
  
end
