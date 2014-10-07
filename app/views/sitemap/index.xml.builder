cache 'sitemap-index' do
  xml.instruct!
  xml.urlset(
    'xmlns'.to_sym => "http://www.sitemaps.org/schemas/sitemap/0.9"
  ) do
    @pages.each do |category, count|
      count.times do |i|
        xml.url do
          xml.loc sitemap_url(category: category, page: i+1)
        end
      end
    end
  end
end