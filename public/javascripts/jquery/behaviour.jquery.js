(function($) {
    
Hover = $.klass({
  initialize: function(hoverClass) {
    this.hoverClass = hoverClass;
  },
  onmouseover: function() {
    this.element.addClass(this.hoverClass);
  },
  onmouseout: function() {
    this.element.removeClass(this.hoverClass);
  }
});

Popup = $.klass({
  initialize: function(options) {
    this.options = Object.extend({
        trigger: 'hoverIntent',
        ajaxPath: ['this.href'],
        ajaxLoading: '<img src="/images/dark-spinner.gif" width="16px" height="16px"/>',
        fill: '#000',
        cssStyles: {
            fontFamily: 'Arial, "Helvetica Neue", Helvetica, sans-serif',
            fontSize: '11px',
            width: 'auto',
            color: 'white'
        },
        width: '400px',
        strokeWidth: 1,
        strokeStyle: 'black',
        hoverIntentOpts:  { interval: 300, timeout: 500 },
        positions: ['left', 'right', 'top'],
        closeWhenOthersOpen: true},
    options || {
    });
    this.element.bt(this.options);
  },
  onclick: function(){
    this.element.btOff();
  }
});

//override Popup to process scripts after the div has been load and displayed  
AjaxPopup = $.klass(Popup, {
  initialize: function($super, options) {
    request = this;
    this.scripts = [];
    this.options = Object.extend({
      ajaxOpts: {dataType: 'html', success: this.capture_scripts},
      ajaxCache: 'false',
      postShow: function(box) {
        request.scripts.each(function() {
          request.evaluate_script(this.text || this.textContent || this.innerHTML || "");
        });
      }}, options || {});
    $super(this.options);
  },
  capture_scripts: function(data, status){
    request.scripts = $('script', data);
  },
  evaluate_script: function(script){
    try{
      if (window.execScript) window.execScript(script); else eval.call(null, script); //fix ie gheyness
    } catch(e){
      jQuery.fbDebug(function(){console.error('exception: %o on script: %s', e, script)});
    }
  }
});

//Async behaviour placed on Form objects, ie radio and checkboxes. Posts form on behaviour trigger. Evaluates returned js
//options.form - required - Form to which element belongs
//options.hide - optional element to hide on init
//options.spinner - optional element to replace with a spinner onchange
FormSelectionOnChange = $.klass(Remote.Base, {
  initialize: function($super, options){
    if (options.form){
      this.form = $(options.form);
        options = $.extend({
          url  : this.form.attr('action'),
          type : this.form.attr('method') || 'get'
        }, options || {});
    }  else {throw('A Form must be defined using form:...');}
    if (options.hide) {$(options.hide).hide();}
    if (options.spinner) {this.spinner = $(options.spinner);}
    //call inherited
    $super(options);
  },
  onclick: function() {
    if (this.spinner) { this.spinner.html('<div class="spinner"><img src="/images/spinner.gif" /></div>'); }
    this.options.data = this.form.serialize();
    this._makeRequest(this.options);
  }
});

RemoteUpdateSelectOnChange = $.klass(Remote.Base, {
  initialize: function($super, options) {
    if (!options.url){ $.fbDebug(function() {console.error('url not defined during bind')}); }
    options.evalScripts = true;
    $super(options);
  },
  onchange: function() {
    select_options = this.element.attr('options');
    opt_sel = select_options[select_options.selectedIndex].value;
    options = $.extend({
        data:  'type=' +opt_sel,
        method : 'get'
      },  this.options);
    return this._makeRequest(options);
  }
});

//behaviour to update with a blind down on a Remote get  
//WARNING - has dependants - check prior to making any modifications   
RemoteUpdateBlindShow = $.klass(Remote.LinkLive, {
  onclick: function($super){
    //initialize update here as subsequent content might have been dynamically added since init
    update = $(this.options.update);
    update.show();
    update.html('<div class="spinner"><img src="/images/spinner.gif" /></div>');
    $super();
    return false;
  },
  onupdate: function($super, data, status){
    //initialize update here as subsequent content might have been dynamically added since init
    update = $(request.options.update);
    update.slideToggle(500, function() {
      $super(data, status);
      update.slideToggle(500, function() {
         $.scrollTo(this, 500, {offset: -100, onAfter: function(){
            if (request.options.focus) $(request.options.focus).focus();
         }});
      });
    });
  }
});

//behaviour blind closes container & clears content
RemoteUpdateBlindClose = $.klass(Remote.Link, {
  initialize: function($super, options) {
    this.update = $(options.update);
    $super(options);
  },
  onclick: function() {
    this.update.slideToggle(500, function() {
      $.scrollTo(this, 500, {offset: -200, onAfter: function() {
        this.empty();
      } });
    });
    return false;
  }
});


})(jQuery);

