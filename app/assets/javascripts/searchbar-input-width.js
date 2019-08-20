//Adjust searchbar input field width according to placeholder length
$(document).ready(function() {
  $(".search-input").width(
    $("input#query.search-input")[0].placeholder.length * 10
  );
});
