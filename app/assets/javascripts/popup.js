$(window).load(function() {

  if ($('.signed_out').length) {
    $('.signed_out').on('click', function(ev) {
      ev.preventDefault();
      $('.popup.is-hidden').removeClass('is-hidden');
    });
    $('.popup-close').on('click', function() {
      $('.popup').addClass('is-hidden');
    });
  }

});
