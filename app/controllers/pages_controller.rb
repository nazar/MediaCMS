class PagesController < ApplicationController

  def index
    render :action => :best_viewed_with_firefox
  end
  
  def contact_us
    return if request.get?
    AdminMailer.deliver_contact_us( params, request.remote_ip )
    step_notice('<h3>Your message was sent</h3>')
  end
  
  def preview
    message = params[:markup_message].blank? || params[:markup_message].blank? ? '' : params[:markup_message]
    render :update do |page|
      page.replace_html(:markup_message_viewer, Misc.format_red_cloth(message))
    end
  end

  def lookup
    #TODO remove?
    target = params[:id]
    content = Configuration.send(target)
    render :text => Misc.format_red_cloth(content), :layout => true
  end

  def view
    page = Page.find_by_id params[:id]
    unless page.nil?
      render :text => page.formatted_content, :layout => true
    else
      if ['about_us', 'contact_us', 'support', 'terms_of_service', 'more_information'].include?(params[:name])
        render :action => params[:name]
      else
        step_notice('invalid request')
      end
    end
  end
  
end