class Admin::ArticlesController < Admin::BaseController
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
         
  def list
    @articles = Article.get_unauthorised_articles
  end       
  
  def approve
    article = Article.find(params[:id])
    article.approve
    #
    render :update do |page|
      page.replace_html 'unauthorised', :partial => 'articles/articles', 
                                        :locals => {:articles => Article.get_unauthorised_articles}
    end
  end
  
end