$(document).ready(function() {
  let checkbox = document.getElementById('application_different_data');
  let form = document.getElementById('different_data');
  checkbox.onchange = function() {
     if(this.checked) {
       form.className = "form-field"
     } else {
       form.className = "form-field hidden";
     };
   };
});
