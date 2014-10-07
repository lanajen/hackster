cache ["sitemap-#{@page}-#{@category}"], expires_in: 6.hours do
  xml.instruct!
  xml.urlset(
    'xmlns'.to_sym => "http://www.sitemaps.org/schemas/sitemap/0.9"
  ) do
    get_pages(@category, @page).each do |page|
      xml.url do
        xml.loc page[:loc]
        xml.changefreq page[:changefreq] if page[:changefreq]
        xml.lastmod page[:lastmod] if page[:lastmod]
      end
    end if @ok
  end
end