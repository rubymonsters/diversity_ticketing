$(document).ready(function() {
  let checkbox = document.getElementById('different_data');
  let form = document.getElementById('form_different_data');
  let user_information = document.getElementById('user_profile_information');
  checkbox.onchange = function() {
     if(this.checked) {
       form.className = "form_field";
       user_information.className = "form_field--hidden";
     } else {
       form.className = "form_field--hidden";
       user_information.className = "form_field";
     };
   };
});
