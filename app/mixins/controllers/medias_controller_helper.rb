module MediasControllerHelper
  

  def get_licenses_and_calc_price
    if not params[:license].blank?
      @licenses = MediaLicensePrice.find(params[:license].keys)
    elsif not @media.media_license_prices.blank? #no license given as this could be the only license choice... chose first license for media
      @licenses = [@media.media_license_prices.first]
    else
      @licenses = []
    end
    @price = @media.price
    @licenses.each{|license| @price += license.price}
  end

  def get_media_lic_options_and_price
    license_prices    = @media.media_license_prices
    #
    @adv_lic        = Configuration.multiple_license_prices && (license_prices.length > 0)
    #determine the media's starting price depending on the above if price has not already been set (can be set in order_controller.buy
    if @price.nil?
      if @adv_lic
        #advanced... set price to be first of resolutions (if exists) and licenses (if exists)
        @price  = @media.price
        @price += license_prices.first.price unless license_prices.blank?
      else
        @price = @media.price
      end
    end
  end

  protected :get_licenses_and_calc_price, :get_media_lic_options_and_price

end