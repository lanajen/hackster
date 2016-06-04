module IncomingEmail
  module Resolver
    class Base
      def initialize initial_comment
        @initial_comment = initial_comment
      end

      def initialize_new_comment user, body
        new_comment = Comment.new raw_body: body
        new_comment.commentable = @initial_comment.commentable
        new_comment.user_id = user.id
        new_comment
      end

      def post_comment user, body
        raise "undefined method"
      end
    end
  end
end