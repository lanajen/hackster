class ArticleDecorator < BaseArticleDecorator
  def to_share_message
    sentences = ['I love this:', 'Check this out:', 'Cool stuff:', 'Awesome:', 'Nice!']

    user = model.users.first
    user_name = model.guest_name.presence
    user_name = user.twitter_handle || user.name if !user_name and user
    "#{sentences.sample} #{model.name} by #{user_name}"
  end
end