module IncomingEmail
  class Handler
    def initialize user
      @user = user
    end

    def post_comment initial_comment, body
      "IncomingEmail::Resolver::#{initial_comment.commentable_type}"
        .constantize.new(initial_comment).post_comment(@user, body)
    end
  end
end