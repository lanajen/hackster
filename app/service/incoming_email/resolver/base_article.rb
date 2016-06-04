module IncomingEmail
  module Resolver
    class BaseArticle < Base
      def post_comment user, body
        new_comment = initialize_new_comment user, body
        new_comment.parent_id = (
          @initial_comment.is_root? ?
          @initial_comment.id :
          @initial_comment.parent_id
        )
        new_comment.save
      end
    end
  end
end