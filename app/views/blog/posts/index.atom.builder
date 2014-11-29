atom_feed language: 'en-US', root_url: blog_index_url do |feed|
  feed.title title
  feed.updated @posts.first.published_at

  @posts.each do |post|
    feed.entry(post, url: blog_post_url(post.slug), published: post.published_at, id: "tag:www.hackster.io/blog/#{post.id}") do |entry|
      entry.url blog_post_url(post.slug)
      entry.title post.title
      entry.content strip_tags(post.excerpt)

      # the strftime is needed to work with Google Reader.
      entry.updated(post.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
    end
  end
end