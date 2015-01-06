client = new Faye.Client('/faye')

scrollToLastMessage = ->
  $('.chat-inner').scrollTop($('.chat-inner ul').height())

jQuery ->
  client.on 'transport:down', ->
    # the client is offline
    console.log("we're offline, please wait while we try to reconnect...")
    $('textarea[name="chat_message[body]"]').prop('disabled', true)

  client.on 'transport:up', ->
    # the client is online
    console.log("we're online")
    $('textarea[name="chat_message[body]"]').prop('disabled', false).focus()

  channelId = $('meta[name=channel_id]').attr('content')
  client.addExtension {
    outgoing: (message, callback) ->
      message.ext = message.ext || {}
      message.ext.csrfToken = $('meta[name=csrf-token]').attr('content')
      callback(message)
  }

  try
    client.unsubscribe '/chats/' + channelId
  catch
    console?.log "Can't unsubscribe." # print a message only if console is defined

  sub = client.subscribe '/chats/' + channelId, (payload) ->
    console.log(payload)
    if payload.tpl
      $.each payload.tpl, (i, tpl) ->
        $(tpl.target).append(tpl.content)
        scrollToLastMessage()

    # if payload.subscribed
      # increment user count

    # if payload.disconnected
    #   userThumb = $("#participant-#{payload.disconnected}")
    #   userName = userThumb.data('user-name')
    #   $('#chat .messages').append("<li>#{userName} left.</li>")
    #   scrollToLastMessage()
    #   userThumb.remove()
    #   # decrement user count

  # sub.then ->
  #   client.publish '/chats/' + channelId,
  #     subscribed: current_user_details.id
  #     tpl:
  #       [
  #         {
  #           content: "<li>#{current_user_details.name} joined.</li>"
  #           target: "#chat .messages"
  #         }
  #         {
  #           content: current_user_thumb
  #           target: ".chat-participants ul"
  #         }
  #       ]

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

    window.addEventListener "beforeunload", ((e) ->
      sub.cancel()
    ), false

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