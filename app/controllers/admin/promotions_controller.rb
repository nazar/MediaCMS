class Admin::PromotionsController < Admin::BaseController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @promotion_pages, @promotions = paginate :promotions, :per_page => 10
  end

  def show
    @promotion = Promotion.find(params[:id])
  end

  def new
    @promotion = Promotion.new
    @promotion.code = String.random_string(20)
  end

  def create
    @promotion = Promotion.new(params[:promotion])
    if @promotion.save
      flash[:notice] = 'Promotion was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @promotion = Promotion.find(params[:id])
  end
  
  def ebay_listing
    @promotion = Promotion.find(params[:id])
    object      = @promotion.link_object
    if object.class == Photo
      @photo     = object
      render :action => :ebay_listing
    elsif object.class == Collection 
      @collection = object
      render :action => :ebay_collection_listing
    end
  end

  def update
    @promotion = Promotion.find(params[:id])
    if @promotion.update_attributes(params[:promotion])
      flash[:notice] = 'Promotion was successfully updated.'
      redirect_to :action => 'show', :id => @promotion
    else
      render :action => 'edit'
    end
  end

  def destroy
    Promotion.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def new_email
    #item is bought... update buy counters on collection and photos
    Promotion.transaction do
      @promotion = Promotion.find(params[:id])
      @promotion_email = PromotionEmail.create_and_link(@promotion, params[:promotion_email])
      #register uses and bought counters
      expire_left_block
      @promotion.register_new_purchase(@promotion_email)
      #generate email to user with promotion code and instructions
      UserMailer.deliver_promotion_code(@promotion, @promotion_email)
    end
  end
  
  def delete_email
    promotion_email = PromotionEmail.find(params[:id])
    
    promotion       = promotion_email.promotion
    promotion.strict = promotion.promotion_emails.count == 1
    promotion.uses_remaining -= 1
    promotion.save
    
    @deleted_email   = promotion_email.id
    promotion_email.destroy
  end
  
  def lookup_object
    model = params[:type].to_s.constantize
    obj   = model.find(params[:id])
    #
    render :update do |page|
      if model == Collection
        page.replace_html 'display_object', :partial => '/collections/collection_snapshot',
                                            :locals => {:collection => obj}
      elsif model = Photo      
        page.replace_html 'display_object', photo_block(obj)
      end
    end
  end
  
end
