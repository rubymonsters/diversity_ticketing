//Adjust searchbar input field width according to placeholder length
$(document).ready(function() {
  console.log($("#query.search-input")[0].placeholder.length);
  $(".search-input").width(
    $("input#query.search-input")[0].placeholder.length * 10
  );
});
