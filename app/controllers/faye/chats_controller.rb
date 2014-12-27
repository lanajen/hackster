class Faye::ChatsController < FayeRails::Controller
  channel '/chats/*' do
    subscribe do
      puts "Received on #{channel}"
    end

    monitor :subscribe do
      puts "Client #{client_id} subscribed to #{channel}."
    end
    monitor :unsubscribe do
      puts "Client #{client_id} unsubscribed from #{channel}."
    end
    monitor :publish do
      puts "#{Time.now}: Client #{client_id} published #{data.inspect} to #{channel}."

      # created_at = if data['created_at'].present?
      #   Time.parse(data['created_at'])
      # else
      #   Time.now
      # end

      # ChatMessage.create user_id: data['user_id'], message: data['message'],
      #   group_id: data['group_id'], created_at: created_at
    end

    filter :in do
      # if the message won't save we block it
      # message = ChatMessage.create user_id: data['user_id'], message: data['message'],
      #   group_id: data['group_id'], created_at: created_at

      # message.valid? ? pass : block(message.errors.messages)
      pass
    end
  end
end