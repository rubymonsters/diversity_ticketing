$(document).ready(function(){
  $( "#account-menu" ).click(function() {
    $(".dropdown-content").toggle();
  });

  //makes menu disappear when you click somewhere else on the page:
  $(document).click(function() {
    if ($(".dropdown-content").is( ":visible" )) {
      if ($(event.target).is('#dropdown *')) {
        return;
      }
      else {
        $(".dropdown-content").toggle();
      }
    }
  });
});
