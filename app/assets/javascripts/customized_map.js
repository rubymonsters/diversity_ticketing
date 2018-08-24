(function(){
  this.CustomizedMap = function(countriesStatistics) {
    var mapData = {};
    
    var keys = Object.keys(countriesStatistics);

    keys.forEach(function(key){
      mapData[key] = { fillKey: "events", numberOfEvents: countriesStatistics[key][0], opacityKey: countriesStatistics[key][2], numberOfTickets: countriesStatistics[key][1] };
    });

    map = new Datamap({
      element: document.getElementById("map_events"),
      geographyConfig: {
        highlightBorderColor: '#27AAE1',
        highlightFillColor: '#27AAE1',
        popupTemplate: function(geography, data) {
          return '<div class="hoverinfo"> <p class="hovertitle">' + geography.properties.name + '</p><p>Number of events: ' +  data.numberOfEvents + ' <p>Number of tickets: ' + data.numberOfTickets
        },
        highlightBorderWidth: 1
      },
      projection: 'mercator',
      data: mapData,
      fills: {
        defaultFill: "#E7E8E9",
        events: "#EA5755"
      }
    });
  }
}).call(this);
