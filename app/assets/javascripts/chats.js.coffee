client = new Faye.Client('/faye')

scrollToLastMessage = ->
  $('.chat-inner').scrollTop($('.chat-inner ul').height())

jQuery ->
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

  client.subscribe '/chats/' + channelId, (payload) ->
    console.log(payload)
    $('#chat .messages').append(payload.tpl) if payload.tpl
    scrollToLastMessage()

  $(document).ready ->
    scrollToLastMessage()

    $('#new_chat_message textarea').on 'keypress', (event) ->
      if event.which == 13 && !event.shiftKey
        event.preventDefault();
        $(this).parents('form').submit();

    # auto adjust the height of
    $('#new_chat_message textarea').on 'keyup keydown', ->
      t = $(this);
      console.log t[0].scrollHeight
      if t[0].scrollHeight > 36
        t.css('height', t[0].scrollHeight)
      else
        t.css('height', 36)

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