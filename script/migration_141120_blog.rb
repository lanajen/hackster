Monologue::Post.all.each do |post|
  t = BlogPost.new
  t.body = post.content
  t.title = post.title
  t.public = post.published
  post.tags.each do |tag|
    t.tags.new(name: tag.name)
  end
  t.published_at = post.published_at
  t.slug = post.url
  t.user_id = post.user_id
  t.save
end