class Admin::PagesController < Admin::BaseController

  helper :markup
  
  active_scaffold :pages do |config|
    config.label = "Static Content Pages"
    #override to set display order
    config.list.columns   = [:name, :excerpt, :visible, :updated_at ]
    config.update.columns = [:name, :content, :content_type, :visible]
    config.create.columns = [:name, :content, :content_type, :visible]
    config.show.columns   = [:name, :content_type_desc, :created_by_name, :created_at, :updated_at, :viewed, :visible]
  end   

  protected

  #called by ActiveScaffold before a save
  def before_create_save(record)
    record.updated_by = current_user
  end
  
end
