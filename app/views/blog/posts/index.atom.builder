atom_feed language: 'en-US', root_url: blog_index_url do |feed|
  feed.title title
  feed.updated @posts.first.published_at

  @posts.each do |post|
    feed.entry(post, url: blog_post_url(post.slug), published: post.published_at) do |entry|
      entry.title post.title
      entry.content strip_tags(post.excerpt)
      entry.author do |author|
        author.name post.user.full_name
      end
    end
  end
end