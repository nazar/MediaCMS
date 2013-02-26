(function($) {

//retrieves and shows reply form after current post  
RemoteReplyBlindShow = $.klass(RemoteUpdateBlindShow, {
  initialize: function($super, options) {
    id = this.element.attr('href').match(/(\d+)$/g);
    block = 'reply_block_'+ id;
    options = $.extend({
      url: this.element.attr('href'), type: 'GET',
      id: id,
      after: '#post'+ id,
      block: block,
      update: 'div#'+block } , options || {}
    );
    $super(options);
  },
  onclick: function() {
    $(this.options.update).remove();
    $(this.options.after).after('<div id="'+this.options.block+'" style="display: none"><div class="spinner"><img src="/images/spinner.gif" /></div></div>');
    $(this.options.update).slideToggle();
    //
    this._makeRequest(this.options);
    return false;
  }
});


})(jQuery);
