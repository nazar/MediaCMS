class  CategoryCache < ActionController::Caching::Sweeper

  observe Category

  def after_create(record)
    expire_cache_for(record)
  end

  def after_update(record)
    expire_cache_for(record)
  end

  def after_destroy(record)
    expire_cache_for(record)
  end

  private

  def expire_cache_for(record)
    expire_fragment( 'categories' )
  end


end