$(document).ready(function() {
  // Markdown previewer for textareas

  $(".markdown textarea").before("<span class='hint'>Styling with Markdown is supported</span>" +
                                 "<div class='tab active markdown_btn'>Write</div>" +
                                 "<div class='tab markdown_preview_btn'>Preview</div>");
  $(".markdown textarea").after("<div class='markdown_preview'>" +
                                  "<div class='markdown_preview_inner'></div>" +
                                "</div>");
  $(".markdown_preview").hide();

  $(".markdown textarea").on('input', function(event) {
    var markdownized = marked($(this).val());
    $(event.target).closest(".markdown").find(".markdown_preview_inner").html(markdownized);
  });

  $(".markdown_preview_btn").on('click', function(event) {
    if ( !$(this).hasClass('active') ) {
      var element = $(event.target).closest(".markdown");
      element.find(".markdown_btn").toggleClass("active");
      $(this).toggleClass("active");
      element.find("textarea").toggle();
      element.find(".markdown_preview").toggle();
    }
    return false;
  })

  $(".markdown_btn").on('click', function(event) {
    if ( !$(this).hasClass('active') ) {
      var element = $(event.target).closest(".markdown");
      $(this).toggleClass("active");
      element.find(".markdown_preview_btn").toggleClass("active");
      element.find("textarea").toggle();
      element.find(".markdown_preview").toggle();
    }
    return false;
  })


  // convert and show the text in views

  $(".markdownize").replaceWith(function() {
    return marked($(this).text());
  });
});
