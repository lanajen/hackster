xml.instruct!
xml.urlset(
  'xmlns'.to_sym => "http://www.sitemaps.org/schemas/sitemap/0.9"
) do
  @count.times do |i|
    xml.url do
      xml.loc sitemap_url(page: i+1)
    end
  end
end