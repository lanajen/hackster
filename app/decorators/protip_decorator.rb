class ProtipDecorator < ProjectDecorator
  def to_share_message
    sentences = ['I love this:', 'Check this out:', 'Cool stuff:', 'Awesome:', 'Nice!']

    user = model.users.first
    "#{sentences.sample} #{model.name} by #{user.twitter_handle || user.name}"
  end
end