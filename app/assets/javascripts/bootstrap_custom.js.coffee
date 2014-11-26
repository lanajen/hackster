jQuery ->
  $("a[rel=popover], .ispopover").popover(content: $(this).next('.popover').html())
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  $(".istooltip").tooltip()
  $('body').tooltip({
    selector: '.istooltip'
  });