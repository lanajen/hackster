client = new Pusher('a052792b761bf6079a9a')
Pusher.log = (message) ->
  if (window.console && window.console.log)
    window.console.log(message)

scrollToLastMessage = ->
  $('.chat-inner').scrollTop($('.chat-inner ul').height())

jQuery ->
  channelId = $('meta[name=channel_id]').attr('content')
  sub = client.subscribe('group_' + channelId)
  sub.bind 'pusher:subscription_succeeded', (payload) ->
    $('textarea[name="chat_message[body]"]').prop('disabled', false).focus()

  sub.bind 'new:message', (payload) ->
    console.log(payload)
    if payload.tpl
      $.each payload.tpl, (i, tpl) ->
        $(tpl.target).append(tpl.content)
        scrollToLastMessage()

  client.connection.bind 'connected', ->
    $('textarea[name="chat_message[body]"]').prop('disabled', false).focus()

  client.connection.bind 'connecting', ->
    $('textarea[name="chat_message[body]"]').prop('disabled', true)

  $(document).ready ->
    scrollToLastMessage()

    $('#new_chat_message textarea').on 'keypress', (event) ->
      if event.which == 13 && !event.shiftKey
        event.preventDefault()
        # $(this).parents('form').submit()
        that = this
        body = $(this).val()
        $(this).prop('disabled', true)
        $.ajax
          url: $(this).parents("form").attr("action")
          type: 'POST'
          data:
            chat_message:
              body: body

          success: (response) ->
            $(that).val("").css("height", 36).prop("disabled", false).focus()

    # auto adjust the height of
    $('#new_chat_message textarea').on 'keyup keydown', ->
      t = $(this);
      # console.log t[0].scrollHeight
      if t[0].scrollHeight > 36
        t.css('height', t[0].scrollHeight)
      else
        t.css('height', 36)

    # window.addEventListener "beforeunload", ((e) ->
    #   sub.cancel()
    # ), false

  #   $('form').submit (event) ->
  #     event.preventDefault()

  #     # button.attr('disabled', 'disabled')
  #     # button.val('Posting...')
  #     publication = client.publish '/chats/' + channelId,
  #       message: input.val()
  #       created_at: new Date()
  #     publication.callback ->
  #       input.val('')
  #       # button.removeAttr('disabled')
  #       # button.val("Post")
  #     publication.errback ->
  #       # button.removeAttr('disabled')
  #       # button.val("Try Again")
  #       console.log('error')

# in case anyone wants to play with the inspector.
window.client = client