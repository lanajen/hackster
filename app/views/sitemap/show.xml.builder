xml.instruct!
xml.urlset(
  'xmlns'.to_sym => "http://www.sitemaps.org/schemas/sitemap/0.9"
) do
  @sitemap_pages.each do |page|
    xml.url do
      xml.loc page[:loc]
      xml.changefreq page[:changefreq] if page[:changefreq]
      xml.lastmod page[:lastmod] if page[:lastmod]
    end
  end if @sitemap_pages
end