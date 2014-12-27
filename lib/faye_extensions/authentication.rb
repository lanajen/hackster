module Faye
  class Authentication
    def incoming(message, request, callback)

      message['data'] = {} unless 'data'.in? message

      begin
        message['data']['user_id'] = request.session["warden.user.user.key"][0][0]
        if channel = message['channel'] and channel =~ /\A\/chats\//
          message['data']['group_id'] = channel.split(/\//)[2]
        end
      rescue
        message['error'] = '401::Access denied'
      end

      callback.call(message)
    end
  end
end