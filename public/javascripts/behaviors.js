DateSelector = Behavior.create({
  initialize: function(options) {
    this.element.addClassName('date_selector');
    this.calendar = null;
    this.options = Object.extend(DateSelector.DEFAULTS, options || {});
    this.date = this.getDate();
    this._createCalendar();
  },
  setDate : function(value) {
    this.date = value;
    this.element.value = this.options.setter(this.date);

    if (this.calendar)
      setTimeout(this.calendar.element.hide.bind(this.calendar.element), 500);
  },
  _createCalendar : function() {
    var calendar = $div({ 'class' : 'date_selector' });
    document.body.appendChild(calendar);
    calendar.setStyle({
      position : 'absolute',
      zIndex : '500',
      top : Position.cumulativeOffset(this.element)[1] + this.element.getHeight() + 'px',
      left : Position.cumulativeOffset(this.element)[0] + 'px'
    });
    this.calendar = new Calendar(calendar, this);
  },
  onclick : function(e) {
    this.calendar.show();
    Event.stop(e);
  },
  onfocus : function(e) {
    this.onclick(e);
  },
  getDate : function() {
    return this.options.getter(this.element.value) || new Date;
  }
});

Calendar = Behavior.create({
  initialize : function(selector) {
    this.selector = selector;
    this.element.hide();
    Event.observe(document, 'click', this.element.hide.bind(this.element));
  },
  show : function() {
    Calendar.instances.invoke('hide');
    this.date = this.selector.getDate();
    this.redraw();
    this.element.show();
    this.active = true;
  },
  hide : function() {
    this.element.hide();
    this.active = false;
  },
  redraw : function() {
    var html = '<table class="calendar">' +
               '  <thead>' +
               '    <tr><th class="back"><a href="#">&larr;</a></th>' +
               '        <th colspan="5" class="month_label">' + this._label() + '</th>' +
               '        <th class="forward"><a href="#">&rarr;</a></th></tr>' +
               '    <tr class="day_header">' + this._dayRows() + '</tr>' +
               '  </thead>' +
               '  <tbody>';
    html +=    this._buildDateCells();
    html +=    '</tbody></table>';
    this.element.innerHTML = html;
  },
  onclick : function(e) {
    var source = Event.element(e);
    Event.stop(e);

    if ($(source.parentNode).hasClassName('day')) return this._setDate(source);
    if ($(source.parentNode).hasClassName('back')) return this._backMonth();
    if ($(source.parentNode).hasClassName('forward')) return this._forwardMonth();
  },
  _setDate : function(source) {
    if (source.innerHTML.strip() != '') {
      this.date.setDate(parseInt(source.innerHTML));
      this.selector.setDate(this.date);
      this.element.getElementsByClassName('selected').invoke('removeClassName', 'selected');
      source.parentNode.addClassName('selected');
    }
  },
  _backMonth : function() {
    this.date.setMonth(this.date.getMonth() - 1);
    this.redraw();
    return false;
  },
  _forwardMonth : function() {
    this.date.setMonth(this.date.getMonth() + 1);
    this.redraw();
    return false;
  },
  _getDateFromSelector : function() {
    this.date = new Date(this.selector.date.getTime());
  },
  _firstDay : function(month, year) {
    return new Date(year, month, 1).getDay();
  },
  _monthLength : function(month, year) {
    var length = Calendar.MONTHS[month].days;
    return (month == 1 && (year % 4 == 0) && (year % 100 != 0)) ? 29 : length;
  },
  _label : function() {
    return Calendar.MONTHS[this.date.getMonth()].label + ' ' + this.date.getFullYear();
  },
  _dayRows : function() {
    for (var i = 0, html='', day; day = Calendar.DAYS[i]; i++)
      html += '<th>' + day + '</th>';
    return html;
  },
  _buildDateCells : function() {
    var month = this.date.getMonth(), year = this.date.getFullYear();
    var day = 1, monthLength = this._monthLength(month, year), firstDay = this._firstDay(month, year);

    for (var i = 0, html = '<tr>'; i < 9; i++) {
      for (var j = 0; j <= 6; j++) {

        if (day <= monthLength && (i > 0 || j >= firstDay)) {
          var classes = ['day'];

          if (this._compareDate(new Date, year, month, day)) classes.push('today');
          if (this._compareDate(this.selector.date, year, month, day)) classes.push('selected');

          html += '<td class="' + classes.join(' ') + '">' +
                  '<a href="#">' + day++ + '</a>' +
                  '</td>';
        } else html += '<td></td>';
      }

      if (day > monthLength) break;
      else html += '</tr><tr>';
    }

    return html + '</tr>';
  },
  _compareDate : function(date, year, month, day) {
    return date.getFullYear() == year &&
           date.getMonth() == month &&
           date.getDate() == day;
  }
});

DateSelector.DEFAULTS = {
  setter: function(date) {
    return [
      date.getFullYear(),
      date.getMonth() + 1,
      date.getDate()
    ].join('/');
  },
  getter: function(value) {
    var parsed = Date.parse(value);

    if (!isNaN(parsed)) return new Date(parsed);
    else return null;
  }
}

Object.extend(Calendar, {
  DAYS : $w('S M T W T F S'),
  MONTHS : [
    { label : 'January', days : 31 },
    { label : 'February', days : 28 },
    { label : 'March', days : 31 },
    { label : 'April', days : 30 },
    { label : 'May', days : 31 },
    { label : 'June', days : 30 },
    { label : 'July', days : 31 },
    { label : 'August', days : 31 },
    { label : 'September', days : 30 },
    { label : 'October', days : 31 },
    { label : 'November', days : 30 },
    { label : 'December', days : 31 }
  ]
});

Draggable = Behavior.create({
  initialize : function(options) {
    this.options = Object.extend({
      onStart : Prototype.K,
      onComplete : Prototype.K,
      units : 'px',
      zindex : 1000,
      revert : true
    }, options || {});

    this.handle = this.options.handle || this.element;
    Draggable.Handle.attach(this.handle, this);

    this.element.makePositioned();

    this.startX = this.element.getStyle('left') || '0px';
    this.startY = this.element.getStyle('top') || '0px';
    this.startZ = this.element.getStyle('z-index');

    Draggable.draggables.push(this);
  },
  move : function(x, y) {
    this.element.setStyle({
      left : (parseInt(this.element.getStyle('left')) || 0) + x + this.options.units,
      top : (parseInt(this.element.getStyle('top')) || 0) + y + this.options.units
    });
  },
  drag : function(e) {
    this.clientX = e.clientX;
		this.clientY = e.clientY;
		this.move(this.clientX - this.lastMouseX, this.clientY - this.lastMouseY)
    this.set(e);
		return false;
  },
  set :function(e) {
    this.lastMouseX = e.clientX;
		this.lastMouseY = e.clientY;
  },
  stop : function() {
    this.unbindDocumentEvents();

    Draggable.targets.each(function(target) {
      if (Position.within(target.element, this.clientX, this.clientY)) {
        target.onDrop(this);
      }
    }.bind(this));

    this.options.onComplete(this);

    if (this.options.revert) {
      if (typeof this.options.revert == 'function') {
        this.options.revert(this);
      } else this.element.setStyle({
        left : this.startX,
         top : this.startY
      });
    }

    this.element.style.zIndex = this.startZ;
  },
  bindDocumentEvents : function() {
    document.onmousemove = this.drag.bindAsEventListener(this);
    document.onmouseup = this.stop.bindAsEventListener(this);
  },
  unbindDocumentEvents : function() {
    document.onmousemove = document.onmouseup = null;
  }
});

Draggable.Handle = Behavior.create({
  initialize : function(draggable) {
    this.draggable = draggable;
  },
  onmousedown : function(e) {
		this.draggable.bindDocumentEvents();
		this.draggable.set(e);
		this.draggable.element.style.zIndex = this.draggable.options.zindex;
		this.draggable.options.onStart(this.draggable);
		return false;
  }
});

Draggable.draggables = [];
Draggable.targets = [];

Draggable.DropTarget = Behavior.create({
  initialize : function(options) {
    this.options = Object.extend({
      onDrop : Prototype.K
    }, options || {});

    Draggable.targets.push(this);
  },
  onDrop : function(draggable) {
    if (this.canDrop(draggable))
      return this.options.onDrop.call(this, draggable);
    else return false;
  },
  canDrop : function(draggable) {
    return !this.options.accepts || draggable.element.hasClassName(this.options.accepts);
  }
});

//Form.Methods.serialize = function(form, getHash, buttonPressed) {
//  var elements = Form.getElements(form).reject(function(element) {
//    return ['submit', 'button', 'image'].include(element.type);
//  });
//
//  if (buttonPressed || (buttonPressed = form.getElementsBySelector('*[type=submit]').first()))
//    elements.push(buttonPressed);
//
//  return Form.serializeElements(elements, getHash);
//}
//
//Element.addMethods();

BlindCloseControl = Behavior.create({
  initialize : function(options) {
    this.options = Object.extend({ evaluateScripts : true }, options || {});
    this.control = $(this.options.control);
  },
  onclick : function() {
    Effect.toggle( this.control,'blind',
                  {duration:1.0, afterFinish:function(effect) { $( effect.element.id ).remove(); }}
                 );
    return false;
  }
});

BlindClearControl = Behavior.create({
  initialize : function(options) {
    this.options = Object.extend({ evalScripts : true }, options || {});
    this.control = $(this.options.control);
  },
  onclick : function() {
    Effect.toggle( this.control,'blind',
                  {duration:1.0, afterFinish:function(effect) { $(effect.element.id).innerHTML = ''; }}
                 );
    return false;
  }
});


Remote.SelectOnChange = Behavior.create(Remote.Base, {
  onchange : function() {
    opt_sel = this.element.options[this.element.selectedIndex].value;
    var options = Object.extend({ method : 'get' }, this.options);
    options.url = options.url + '?selected=' + opt_sel + '&el=' + this.element.id;
    return this._makeRequest(options);
  }
});

//Async behaviour placed on Form objects, ie radio and checkboxes. Posts form on behaviour trigger. Evaluates returned js
//options.form - required - Form to which element belongs
//options.hide - optional element to hide on init
//options.spinner - optional element to replace with a spinner onchange
Remote.FormSelectionOnChange=Behavior.create(Remote.Base, {
  initialize: function(options){
    if (options.form){
      this.form   = $(options.form)
      this.options = Object.extend({
          evalScripts: true,
          url : this.form.action,
          method : this.form.method || 'get'
        }, options || {});
    }  else {throw('A Form must be defined using form:...');}
    if (options.hide) {$(options.hide).hide()}
    if (options.spinner) {this.spinner = $(options.spinner)}
  },
  onchange : function() {
    if (this.spinner) {this.spinner.innerHTML = '<div class="spinner"><img src="/images/spinner.gif" /></div>'}
    this.options.parameters = this.form.serialize();
    return this._makeRequest(this.options);
  }
});

//async ajax update call, with spinner. Always pass an update: xyz option when calling
//ie Event.addBehavior({'a.write_review': BlindDownUpdateControl({ control: 'review_slot' })})
BlindDownUpdateControl = Behavior.create(Remote.Base, {
  initialize : function(options) {
    this.options = Object.extend({ evalScripts: true }, options || {});
    if (this.options.update) this.control = $(this.options.update); else throw('control has not been defined. Define with update: "name"');
  },
  onclick : function() {
    if (this.control) {
      var options = Object.extend({ url : this.element.href, method : 'get',
                                    onComplete: function(response, json){this.BlindUpdateControlCallback(response, json, options);} }, this.options);
      //replace control with spinner
      this.control.innerHTML = '<div class="spinner"><img src="/images/spinner.gif" /></div>'
      this._makeRequest(options);
    }
    return false;
  }
});
function  BlindUpdateControlCallback(response, json, options) {
  var control = $(options.update);
  control.hide();
  control.innerHTML = response.responseText;
  if (options.scroll) {
    new Effect.BlindDown(control, {delay: 0.5, duration: 0.5, afterFinish: function(effect) { $(effect.element.id).scrollTo(); }});
  } else {
    new Effect.BlindDown(control, {delay: 0.5, duration: 0.5});
  }
  return false;
};

//like Remote but defaults to evaluating returned content
RemoteEval = Behavior.create({
  initialize : function(options) {
    this.options = Object.extend({ evalScripts: true }, options || {});
    if (this.element.nodeName == 'FORM') new Remote.Form(this.element, this.options);
    else new Remote.Link(this.element, this.options);
  }
});

//confirm delete

Remote.DeleteLink = Behavior.create(Remote.Base, {
  onclick : function() {
    var options = Object.extend({ url : this.element.href, method : 'post'}, this.options);
    if (confirm('Are you sure you want to delere this item?')){
      return this._makeRequest(options);
    }else{
      return false;
    }
  }

}); 