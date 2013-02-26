module OrdersHelper

  def render_payment_options
    result = ''
    result << content_tag(:div, submit_tag('paypal') << ' Purchase Using Paypal') << '<br />' if Configuration.pay_paypal
    result << content_tag(:div, submit_tag('worldpay') << ' Purchase Using Worldpay' ) if Configuration.pay_worldpay
    result
  end


  def render_order_item_description_column(item)
    objekt = item.object_from_item
    description = case
      when item.item_type == OrderItem::TypeLicense
        "#{link_to(objekt.media.title.humanize, polymorphic_path(objekt.media))} - License: #{link_to(objekt.license.name, license_view_path(objekt.license), {:popup => ['License Information', 'height=600,width=600,scrollbars,resizable']})}"
      when item.item_type == OrderItem::TypePhotoResolution
        "#{link_to(objekt.photo.title.humanize, photo_view_link_path(objekt.photo_id))} - Resolution: #{objekt.width} x #{objekt.height}"
      else
        link_to objekt.title.humanize, polymorphic_path(objekt)
    end
  end

end