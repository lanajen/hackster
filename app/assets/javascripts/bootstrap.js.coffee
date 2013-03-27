jQuery ->
  $("a[rel=popover]").popover(content: $(this).next('.popover').html())
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  $(".istooltip[rel=tooltip]").tooltip()