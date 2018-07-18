(function(){
  this.CustomizedMap = function(eventCountries) {
    var mapData = {};

    var sumEvents = function(a, b){
      return a + b
    };

    var totalEvents = Object.values(eventCountries).reduce(sumEvents);

    defineKeys = function(numberOfEvents) {
      var score = numberOfEvents / totalEvents;
      if (score < 0.25) {
        return 0.25;
      } else if (0.25 < score > 0.5) {
        return 0.5;
      } else if (0.5 < score > 0.75) {
        return 0.75;
      } else {
        return 1;
      }
    };
    var keys = Object.keys(eventCountries);
    keys.forEach(function(key){
      mapData[key] = { fillKey: defineKeys(eventCountries[key]), numberOfEvents: eventCountries[key] };
    });
    new Datamap({
      element: document.getElementById("map_events"),
      geographyConfig: {
        highlightBorderColor: '#bada55',
        popupTemplate: function(geography, data) {
          return '<div class="hoverinfo">' + geography.properties.name + ' <p>Number of events: ' +  data.numberOfEvents
        },
        highlightBorderWidth: 3
      },
      projection: 'mercator',
      data: mapData,
      fills: {
        defaultFill: "#9C9C9C",
        0.25: "#65BE66",
        0.5: "#F8BA3F",
        0.75:"#F0AD4E",
        1: "#EA5755"
      },
      fillOpacity: 0.75
    });
  }
}).call(this);
