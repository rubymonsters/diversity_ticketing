//To fill in event end date and deadline according to start_date for easier form handling
$(document).ready(function(){
  $( "#event_start_date" ).change(function() {
    var date = $("input#event_start_date").val()
    $("#event_end_date").val(date);
    $("#event_deadline").val(date);
  });
});
