class IncomingEmailWorker < BaseWorker
  def process user_hid, comment_hid, body
    user = User.find_by_hid! user_hid
    comment = Comment.find_by_hid! comment_hid

    if user.can? :read, comment.commentable
      IncomingEmail::Responder.new(user).post_message(comment, body)
    end
  end
end