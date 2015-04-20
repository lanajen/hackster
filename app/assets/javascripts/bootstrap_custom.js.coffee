jQuery ->
  $("a[rel=popover], .ispopover").popover(content: $(this).next('.popover').html())
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  $(".istooltip").tooltip()
  $('body').tooltip({
    selector: '.istooltip'
  });

  $('[data-toggle="popover"]').popover().click (e) ->
    e.preventDefault()

  $('body').on 'click', (e) ->
    $('[data-toggle="popover"], .popover-js').each ->
      #the 'is' for buttons that trigger popups
      #the 'has' for icons within a button that triggers a popup
      if !$(this).is(e.target) and $(this).has(e.target).length == 0 and $('.popover').has(e.target).length == 0 and $(this).attr('aria-describedby') != undefined
        $(this).popover 'hide'