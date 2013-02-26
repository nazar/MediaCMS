(function($) {


MarkupShowJSEnabled = $.klass({
  initialize: function() {
    this.element.show();
  }
})

//options... update
MarkupConfirmRemove = $.klass(Remote.Base, {
  initialize: function($super, options) {
    id = this.element.attr('href').match(/(\d+)$/g);
    options = options || {};
    options.control = options.control || 'div#comment-';
    options.update  = options.control + id;
    //sanity check
    if ($(options.update).length == 0) { $.fbDebug(function() {console.error('Could not find update %s', options.update)}); }
    //continue
    $super(options);
  },
  onclick: function() {
    if (confirm('Are you sure you want to action this item?')){
      this._makeRequest({url: this.element.attr('href'),
                        type: this.options.method || 'post' });
    }
    return false;
  },
  onupdate: function(data, status) {
    if (status == 'success') {
      update = $(request.options.update);
      update.slideToggle(500, function() {
        update.empty();
      })
    }
  }
})

//preview(required)  - target x_y_preview container - will deduce that preview div is x_y_preview_target
//control(required)  - textarea control, containing content which will be posted to the markup controller
//method             - post or get... defaults to post
MarkupAreaSlidePreview = $.klass(Remote.Base, {
  initialize: function($super, options) {
    if (options.control) {
      this.control = $(options.control);
      if (this.control.length == 0) {$.fbDebug(function() {console.error(':control %s not found on this page', options.control)})}
      //deduce preview container and target from controler name using: preview = control_preview, target = control_preview_target or preview_target
      options.preview      = options.preview || options.control + '_preview';
      options.update       = options.preview + '_target'
      options.update_class = options.update_class || 'markup-preview';
      //get as objects
      this.preview    = $(options.preview);
      this.update     = $(options.update);
      //sanity check
      if (this.update.length == 0) {$.fbDebug(function() {console.error(':update %s not found on page', options.preview+'_target');})}
      if (this.preview.length == 0) {console.error('update_control %s not found on page', options.preview);}
    } else { $.fbDebug(function() {console.error('Must supply a control: argument');}) }
    //show link
    this.element.show();
    //call to copy options to this.options
    $super(options);
  },
  onclick: function(){
    //send request only if control contains text
    if (this.control.attr('value').length > 0){
      this.update.html('<div class="spinner"><img src="/images/spinner.gif" /></div>');
      this.update.removeClass(this.options.update_class);
      this.preview.show(); //show parent container
      //ajax
      this._makeRequest({url: this.element.attr('href'), 
        type: this.options.method || 'post',
        data: this.control.serialize()});
    }
    return false;
  },
  onupdate: function($super, data, status){
    preview = $(request.preview);
    preview.hide();
    $super(data, status);
    request.update.addClass(request.options.update_class);
    preview.slideToggle('normal', function() {
      $.scrollTo(this, 500, {offset: -200});
    });
  }
});

//control(require) - textarea control, containing content which will be posted to the markup controller
MarkupAreaSlideCloseClearPreview = $.klass({
  initialize: function(options) {
      //deduce link and target names from control, unless overriden
      options = options || {}
      options = $.extend({
        target: options.control + '_preview',
        update: options.control + '_preview_target'
      }, options);
      if (options.control) {
        this.target = $(options.target);
        this.update = $(options.update);
        //sanity check
        if (this.target.length == 0) {$.fbDebug(function() {console.error('target %s not found', options.target);})}
        if (this.update.length == 0) {console.error('update %s not found', options.update);}
      } else {$.fbDebug(function() {console.error('control: not specified')}) }
      //
      this.options = options;
      //all in order... show close link
      this.element.show();
  },
  onclick: function(){
    var markup_target = this.update;
    var control       = $(this.options.control);
    this.target.slideToggle('normal', function() {
      markup_target.empty();
      $.scrollTo(control, 500, {offset: -250});
    });
    return false;
  }
})

//
MarkupAreaFormPostAndScoll = $.klass(Remote.Form,{
  initialize: function($super, options){
    options = options || {};
    options = $.extend({
      append_to: options.append_to || '#last_comment',
      form     : this.element
    }, options);
    $super(options);
  },
  onupdate: function(data, status) { //data will contain name of new comment element
    append_to = $(request.options.append_to);
    append_to.before(data);
    request.options.form.clearForm();
    $.scrollTo(append_to, 500,  {offset: -150});
  }
})


//
MarkupAreaFormUpdateSave = $.klass(Remote.Form, {
  initialize: function($super, options){
    container = this.element.attr('action').match(/(\d+)$/g)
    container = 'div#comment-' + container;
    if ($(container).length == 0) { $.fbDebug(function() {console.error('Could not find container %s', container)}) }
    //
    options = options || {};
    options = $.extend({
      form:        this.element,
      update:      container,
      evalScripts: true
    }, options);
    if (!options.update)    { $.fbDebug(function() {console.error('Could not find update or not defined - %s', options.update);}) }
    //
    $super(options);
  },
  onupdate: function($super, data, status) {
    container = $(request.options.update);
    container.slideToggle(500, function() {
      $super(data, status);
      container.slideToggle(500, function() {
         $.scrollTo(container, 500);
      });
    });
  }
})


AjaxEditArea = $.klass(Remote.Base, {
  initialize: function (options) {
    if (!options.container) {$.fbDebug(function() {console.error('Must specify a container: type i.e. comment, post etc...')})}
    //extract id from href
    target_name = this.element.attr('href').match(/(\d+)$/g)
    target_name = '#' + options.container + '-' + target_name
    this.target = $(target_name);
    //
    this.options = $.extend({
      container  : options.container,
      update     : target_name,
      evalScripts: true
    }, options || {});
    if (this.target.length == 0) {$.fbDebug(function() {console.error('could not find target %s', target_name)}) }
  },
  onclick: function(){
    this_local = this;
    //
    $(this.options.update).slideToggle(300, function() {
      this_local.target.html('<div class="spinner"><img src="/images/spinner.gif" /></div>');
      this_local.target.slideToggle(300, function() {
        this_local._makeRequest({url: this_local.element.attr('href')});
      });
    });
    return false;
  },
  onupdate: function($super, data, status){
    target = $(request.options.update);
    target.slideToggle(300, function() {
      $super(data, status);
      target.slideToggle(300, function() {
        $.scrollTo(target, 500);
      });
    });
  }
});


})(jQuery);

