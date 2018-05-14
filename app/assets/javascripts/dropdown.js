$(document).ready(function(){
  $( "#dropdown-btn" ).click(function() {
    $(".dropdown-content").toggle();
  });

  //makes menu disappear when you click somewhere else on the page:
  $(document).click(function() {
    if ($(".dropdown-content").is( ":visible" )) {
      if ($(event.target).is('#dropdown-btn')) {
        return;
      }
      else {
        $(".dropdown-content").toggle();
      }
    }
  });
});
