class MarkupController < ApplicationController
  
#  def preview_content
#    if params[:control] && params[:object] && (params[:control].length > 0) && (params[:object].length > 0)
#      control = params[:control].to_sym
#      object  = params[:object].to_sym
#      #
#      preview = params[object].blank? || params[object][control].blank? ? '' : params[object][control]
#      render :update do |page|
#        page.replace_html("#{object}_#{control}_viewer".to_sym, Misc.format_red_cloth(preview))
#      end
#    end
#  end

  def preview_content
    #TODO prevent external website calls - process jacking
    return unless request.post?
    if params.index(:content).nil?
      content = content_from_method_name
    else
      content = content_from_target
    end
    unless content.blank?
      rc = RedCloth.new(content)
      content = rc.to_html
    end
    render :text => content
  end

  protected

  def content_from_method_name
    unless params[:control].blank? || params[:object].blank?
      control = params[:control].to_sym
      object  = params[:object].to_sym
      params[object].blank? || params[object][control].blank? ? '' : params[object][control]
    end
  end

  def content_from_target
    unless params[:content].blank? 
      control = params[:content].to_sym
      params[control].blank? ? '' : params[control]
    end
  end

end