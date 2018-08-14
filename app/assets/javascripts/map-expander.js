$(document).ready(function(){
  $(".map-statistics-content").hide();
  $( "#map-expander-btn" ).click(function() {
    $(".icon-sort-down-black").toggleClass("rotated");
    $(".map-statistics-content").toggle();
  });

  //makes menu disappear when you click somewhere else on the page:
  $(document).click(function() {
    if ($(".map-statistics-content").is( ":visible" )) {
      if ($(event.target).is('#map-statistics *')) {
        return;
      }
      else {
        $(".icon-sort-down-black").toggleClass("rotated");
        $(".map-statistics-content").toggle();
      }
    }
  });
});
