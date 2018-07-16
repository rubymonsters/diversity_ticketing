(function(){
  this.CustomizedMap = function(eventCountries) {
    var mapData = {};
    eventCountries.forEach(function(element) {
      key = Object.keys(element);
      mapData[key] = { fillKey: "events", numberOfEvents: element[key] };
    });
    var map = new Datamap({
      element: document.getElementById("map_events"),
      geographyConfig: {
        highlightBorderColor: '#bada55',
        popupTemplate: function(geography, data) {
          return '<div class="hoverinfo">' + geography.properties.name + ' Number of events: ' +  data.numberOfEvents
        },
        highlightBorderWidth: 3
      },
      projection: 'mercator',
      data: mapData,
      fills: {
        defaultFill: "#ABDDA4",
        events: "#fa0fa0"
      }
    });
  }
}).call(this);
