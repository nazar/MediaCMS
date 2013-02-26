class ArticlesController < ApplicationController
  helper :forums
  helper :markup
  helper :tags
  
  before_filter :login_required, :except => [ :index, :list, :view]
  
  def index
    list
    render :action=> :list  
  end
  
  #list articles grouped by category
  def list
    @categories = ArticleCategory.find(:all, :order => 'name',:include => :approved_articles) 
    @tag_cloud, @min_count, @max_count = Article.top_tags_min_max(50)
  end
  
  def view
    begin
      @article = Article.find(params[:id])
      #can only view if approved.. otherwise only the author and admin can view
      if @article.approved? 
        #increment read count
        unless current_user && (current_user.id == @article.user_id)
          @article.reads_count += 1
          @article.save 
        end
      else
        render :text => 'Article not approved yet. Please try again later' unless current_user && (current_user.admin? || (current_user.id == @article.user_id))
      end
    rescue
      render :text => 'Article not found.', :layout => true if !@article
    end
  end
  
  def previous_revision
    article  = Article.find(params[:id])
    revision = params[:rev]
    article_body, revision = article.previous_body_revision(revision)
    #
    render :update do |body|
      body.replace('article', :partial => '/articles/article_container', 
                              :locals => {:article => article, :body => Misc.format_red_cloth(article_body),
                              :revision => revision})
    end
  end
  
  def next_revision
    article  = Article.find(params[:id])
    revision = params[:rev]
    article_body, revision = article.next_body_revision(revision)
    #
    render :update do |body|
      body.replace('article', :partial => '/articles/article_container', 
                              :locals => {:article => article, :body => Misc.format_red_cloth(article_body), 
                               :revision => revision})
    end
  end
  
  def my_articles
    @grapher = current_user
  end
  
  def edit
    begin
      @article = Article.find(params[:id])
    rescue
      render :text => 'Article not found', :layout => true
    end
  end
  
  def submit_article
    @grapher = current_user
    @article = Article.new
  end
  
  def save_article
    if params[:article][:id] && (params[:article][:id].to_i > 0)
      @article = Article.find(params[:article][:id])
    else
      @article = Article.new( params[:article] )
      @article.user_id = current_user.id
    end
    #try and revise
    begin
      @article.revise(params[:article],current_user)
      @article.tag_with_by_user(params[:article_tags], current_user)
    rescue ActiveRecord::RecordInvalid
      @grapher = current_user
      render :action => :submit_article
      return
    end
    #display articles if we get here
    redirect_to :action => :my_articles
  end
  
  def admin
    can_admin? do
      #get un-approved articles
      @articles = Article.get_unauthorised_articles
    end  
  end
  
  def approve
    can_admin? do
      article = Article.find(params[:id])
      article.approve_article
      article.save
      #back to up-approved list
      redirect_to(:action => :admin)
    end  
  end
  
  def unapprove
    can_admin? do
      article = Article.find(params[:id])
      article.unapprove_article
      article.save
      #back to up-approved list
      redirect_to(:action => :admin)
    end  
  end
  
end
