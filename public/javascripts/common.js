function toggle(id, s_open, s_closed){
  menu = 'm'+id;
  sub  = 's'+id;
  //
  if (Element.hasClassName(sub,'open')) {
    //hide
    Element.removeClassName(sub,'open');
    Element.addClassName(sub,'closed')
    //replace + with - on parent
    Element.update(menu, s_open)  
  } else if (Element.hasClassName(sub,'closed')) {
    //show
    Element.removeClassName(sub,'closed');
    Element.addClassName(sub,'open')
    //replace - with +  
    Element.update(menu, s_closed)  
  }
}

function toggleControls(toggle, controls) {
  toggle = $(toggle);
  if (toggle.type == 'checkbox')  {
    for (var i = 0; i<controls.length; i++)  {
      if (toggle.checked) {
        Element.hide(controls[i]);  
      } else {
        Element.show(controls[i]);
      }
    }
  }
}

function show_category(id) {
  sub  = 's'+id;
  if (Element.hasClassName(sub, 'closed'))
    Element.removeClassName(sub, 'closed');
  Element.addClassName(sub,'open')      
}

function CheckAllCheckboxes(formname, switchid) {
	var ele = document.forms[formname].elements;
	var switch_cbox = $(switchid);
	for (var i = 0; i < ele.length; i++) {
		var e = ele[i];
		if ( (e.name != switch_cbox.name) && (e.type == 'checkbox') ) {
			e.checked = switch_cbox.checked;
		}
	}
}

function CheckAllCheckboxesByID(formname, switchid, eName) {
  var ele = document.forms[formname].elements;
  var switch_cbox = $(switchid);
  for (var i = 0; i < ele.length; i++) {
    var e = ele[i];
    if ( (e.name != switch_cbox.name) && (e.type == 'checkbox') && (e.id.indexOf(eName) == 0) ) {
      if (e.checked != switch_cbox.checked) {
        e.click();
      }
    }
  }
}

function CheckAllBoxesByClass(control, target_class) {
  control = $(control);
  boxes = $$(target_class);
  boxes.each(function(box) {
    box.checked = control.checked;
  })
}

function catchTab(item, e){
    scrollPos = item.scrollTop;
	if(e.which == 9){
		replaceSelection(item, '  ');
		setTimeout("document.getElementById('"+item.id+"').focus();document.getElementById('"+item.id+"').scrollTop=scrollPos;",0);
		return false;
	}
}

//get all selected options from a listbox 
function getSelected(el) {
  var Ary = {};
  var I = 0;
  element = $(el);
  options = $A(element.options);
  options.each(function(option){
    if (option.selected) {
      Ary['delete['+I+']'] = option.value;
      I++; 
    }
  })
  return Ary;
}

function addEvent(obj, event, fn) {
  jQuery(obj).bind(event, fn);
}

function audioPlayerListner(event) {
  if (event.newstate == 'PLAYING') {
    stopOtherPlayers(event.id, '.audio_preview');
  }
}

function videoPlayerListner(event) {
  if (event.newstate == 'PLAYING') {
    pauseOtherPlayers(event.id, '.video_preview');
  }
}


function stopOtherPlayers(player_id, player_class) {
  players = $$(player_class);
  players.each( function(player) {
    if (player.id != player_id) { player.sendEvent('STOP'); }
  });
}

function pauseOtherPlayers(player_id, player_class) {
  players = $$(player_class);
  players.each( function(player) {
    if (player.id != player_id) { player.sendEvent('PLAY', 'false'); }
  });
}
