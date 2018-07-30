(function(){
  this.CustomizedMap = function(countriesStatistics) {
    var mapData = {};

    var totalEvents = 0;
    var higherNumberOfEvents = 0;

    for(key in countriesStatistics) {
        higherNumberOfEvents = countriesStatistics[key][0] > higherNumberOfEvents ? countriesStatistics[key][0] : higherNumberOfEvents;
        totalEvents = totalEvents + countriesStatistics[key][0];
        var maxScore = higherNumberOfEvents / totalEvents;
    };

  // This "normalizes" the opacity based on the number of events each country has in order to avoid polarization of the values
  // Maybe could be moved to the controller
    defineOpacity = function(numberOfEvents) {
      var countryScore = numberOfEvents / totalEvents;
      return (countryScore / maxScore) + maxScore;
    };

    var keys = Object.keys(countriesStatistics);

    keys.forEach(function(key){
      mapData[key] = { fillKey: "events", numberOfEvents: countriesStatistics[key][0], opacityKey: defineOpacity(countriesStatistics[key][0]), numberOfTickets: countriesStatistics[key][1] };
    });

    map = new Datamap({
      element: document.getElementById("map_events"),
      geographyConfig: {
        highlightBorderColor: '#27AAE1',
        highlightFillColor: '#65BE66',
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
