$(document).ready(function() {
  let checkbox = document.getElementById('different_data');
  let form = document.getElementById('form_different_data');
  checkbox.onchange = function() {
     if(this.checked) {
       form.className = "form_field";
     } else {
       form.className = "form_field--hidden";
     };
   };
});
