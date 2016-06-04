module IncomingEmail
  module Resolver
    class ReviewThread < Base
      def post_comment user, body
        new_comment = initialize_new_comment user, body
        new_comment.save
      end
    end
  end
end