module Faye
  class CsrfProtection
    def incoming(message, request, callback)
      # puts 'csrf'
      return callback.call(message) if message['ext'] && message['ext'].delete('client_event')
      # puts 'went through'
      # puts message['channel']
      # return callback.call(message) unless message['channel'] =~ /\A\/chats\//

      session_token = request.session['_csrf_token']
      message_token = message['ext'] && message['ext'].delete('csrfToken')

      unless session_token == message_token
        puts "failed csrf"
        message['error'] = '401::Access denied'
      end
      callback.call(message)
    end
  end
end