module IncomingEmail
  module Resolver
    class Conversation < Base
      def post_comment user, body
        conversation = @initial_comment.commentable
        conversation.body = body
        conversation.sender_id = user.id
        conversation.save
      end
    end
  end
end