//base class
var GoogleBaseMap = Class.create();
GoogleBaseMap.prototype = {
  initialize: function() { 
    this.init.call(arguments);
  },
  init: function(map_div) {
    if (map_div != undefined) {
      this.centered = false;
      this.rescale  = true;
      //create the google map object
      if (GBrowserIsCompatible()) {
        this.map  = new GMap2($(map_div));
        return this;
      } else {
        alert('Google Maps not supported on this browser.');
        return false;
      }
    } else {
      return false;
    }
  },
  //surface Google's map methods
  addControl: function(obj) {
    this.map.addControl(obj);
  },
  setCenterCoords: function( lat, lon, level){
    this.map.setCenter(GPoint(lat,lon), level);
  },
  setCenter: function(point, level) {
    this.map.centerAndZoom(point,level);
  },
  //abstract methods...don't call
  setupMap: function() {
    alert('Called abstract method. Call appropriate class method instead');
  },
  setup: function() {
    this.addScaleControl();
    this.addMapTypeControl();
    this.map.enableDoubleClickZoom();
    this.map.enableContinuousZoom();
  },
  //controls
  addSmallMapControl: function() {
    this.addControl(new GSmallMapControl());
  },
  addLargeMapControl: function() {
    this.addControl(new GLargeMapControl());
  },
  addMapTypeControl: function() {
    this.addControl(new GMapTypeControl())
  },
  addSmallZoomControl: function() {
    this.addControl(new GSmallZoomControl());
  },
  addScaleControl: function() {
    this.addControl(new GScaleControl());
  },
  addOverviewControl: function() {
    this.addControl(new GOverviewMapControl());
  },
  //  virtual methods
  addMarker: function(row) {      
    coords = row.split('^');
    marker = new GMarker(new GLatLng(coords[0],coords[1]), {title: coords[2] });
    return marker;
  },
  getMapType: function() {
    return G_NORMAL_MAP;
  },
  getZoomLevel: function(bounds) {
    return this.map.getBoundsZoomLevel(bounds);
  },
  //methods
  queryMarkerData: function (qryUrl){
    this.queryUrl = qryUrl;
    GDownloadUrl(this.queryUrl, this.onDataLoad.bind(this) )
  },
  requeryMarkerData: function() {
    this.rescale = false;
    if (this.queryUrl) {this.queryMarkerData(this.queryUrl);}  
  },
  //events
  onDataLoad: function(data, responseCode) {
    if (data != '-1') {
      markers = data.split(';');
      if (markers.length > 0) {
        batch   = [];
        for (var i = 0; i < markers.length; i++) {
          if (marker = this.addMarker(markers[i])) { batch.push(marker); }  
        }
        //center map on first marker
        this.map.clearOverlays();
        if (batch.length > 0) {
          if (this.rescale) { this.map.setCenter(batch[0].getPoint(), 7);}
          //
          var bounds = new GLatLngBounds(); 
          var t = this;
          batch.each( function(value,index){ 
              bounds.extend(value.getPoint());
              t.map.addOverlay(value); 
            }          
          )
          if (this.rescale) {t.map.setCenter(bounds.getCenter(), t.getZoomLevel(bounds), t.getMapType());} 
        } 
      }
    } else {
      this.map.setCenter(new GLatLng(53,5),5);
    }
  }
};

var GoogleSmallMap = Class.create();
GoogleSmallMap.prototype=Object.extend(
  new GoogleBaseMap(),
  { 
    initialize: function(map_div) { 
      this.init(map_div);
    }, 
    setupMap: function() {
      this.setup();
      this.addSmallMapControl();
    }
  } 
);

var GoogleLargeMap = Class.create();
GoogleLargeMap.prototype=Object.extend(
  new GoogleBaseMap(),
  { 
    initialize: function(map_div) { 
      this.init(map_div);
    }, 
    setupMap: function() {
      this.setup();
      this.addLargeMapControl();
      this.addOverviewControl();
    }
  } 
);

//editor class
var GoogleSmallMapEditor = Class.create();
GoogleSmallMapEditor.prototype=Object.extend(
  new GoogleSmallMap(), 
  {
    initialize: function(map_div) { 
      this.init(map_div);
    },
    registerListener: function(e_long,e_lat) {
      this.e_long = $(e_long);
      this.e_lat  = $(e_lat);
      //
      GEvent.addListener(this.map, "click", this.onMapClick.bind(this));
    },
    //events
    onMapClick: function(marker, point) {
      if (marker) {
        point = marker.getPoint();
        this.onMapClick(undefined, point);
      } else  if ((this.e_long && this.e_lat)) {
        this.e_long.value = point.lng();
        this.e_lat.value  = point.lat();
      } 
    }
  }
);

//view class with info windows

var GoogleMapViewer = Class.create();
GoogleMapViewer.prototype=Object.extend(
  new GoogleLargeMap(), 
  {
    initialize: function(map_div) { 
      this.init(map_div);
    },
    //override
    addMarker: function(row) {
      coords = row.split('^');
      var marker = new GMarker(new GLatLng(coords[0],coords[1]), {title: coords[2] });
      marker.photo_id = coords[3];
      //register listener on marker
      GEvent.addListener(marker, "click", function() {
        marker.openInfoWindowHtml("<div class=\"google-map-popup\">Loading details...</div>");
        //
        queryURL = '/photos/get_photo_window_info/'+marker.photo_id;
        GDownloadUrl(queryURL, function(data, responseCode) {
          marker.openInfoWindowHtml(data);
        });
      });
      return marker;
    }
  }
);

//helpers

function getSelectedMarkers(el) {
  Ary = getSelected(el);
  Ary['markable_type'] = $F('markable_type');
  Ary['markable_id'] = $F('markable_id');
  //
  return Hash.toQueryString(Ary);
}