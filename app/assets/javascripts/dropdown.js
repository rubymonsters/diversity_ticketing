$(document).ready(function(){
  $('.dropdown-label').click(function(ev) {
    $(ev.target).find('.icon.sort-down-black').toggleClass('rotated');
    $(ev.target).next('.dropdown-content').toggle();
  });

  //makes menu disappear when you click somewhere else on the page:
  $(document).click(function() {
    if ($(".dropdown-content").is( ":visible" )) {
      if ($(event.target).is('.dropdown *')) {
        return;
      }
      else {
        $(".dropdown-content").hide();
      }
    }
  });
});
