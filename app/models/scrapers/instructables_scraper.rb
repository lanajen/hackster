class InstructablesScraper
  attr_accessor :platform

  def self.scrape_in_bulk platforms
    # platforms = ['Raspberry Pi', 'Arduino', 'Spark Core', 'Electric Imp', 'Teensy', 'Digispark', 'BeagleBoard', 'Intel Galileo', 'Pebble', 'pcDuino', 'TI Launchpad']
    results = {}

    platforms.each do |platform|
      results[platform] = new(platform).scrape
    end

    results
  end

  def initialize platform
    @platform = platform
  end

  def scrape
    puts "[Scraper] Scraping instructables.com for #{platform}"
    offset = 0
    results = { errors: [], successes: 0, skips: 0 }

    while true do
      p=ProjectScraper.new "http://www.instructables.com/tag/type-id/category-technology/?sort=none&partial=true&q=#{CGI.escape(platform)}&count=50&offset=#{offset}&page=1&sort=RECENT"
      parsed = Nokogiri::HTML p.scrape
      lis = parsed.css('li')
      break if lis.empty?
      lis.each do |li|
        begin
          next unless li.at_css('.views')
          name = li.at_css('.title').text.strip
          author = li.at_css('.author').text.gsub(/by/, '').strip
          link = 'http://www.instructables.com' + li.at_css('.title a')['href']
          if project = Project.find_by_website(link)
            puts "[Scraper] Found existing project on instructables.com: #{link}"
            if project.external? and project.approved.nil?
              project.platform_tags_string += ",#{platform}" unless project.platform_tags_string =~ Regexp.new(platform)
              project.save
            end
            results[:skips] += 1
          else
            puts "[Scraper] Scraping project in #{platform}: #{name} at #{link}"
            image = li.at_css('img')['src'].gsub(/RECTANGLE1/, 'LARGE')
            project = Project.new name: name, guest_name: author, website: link, one_liner: name, platform_tags_string: platform
            project.build_cover_image
            project.cover_image.remote_file_url = image
            project.external = true
            if project.save
              results[:successes] += 1
            else
              puts "[Scraper] Couldn't save #{link}: #{project.errors.inspect}"
              results[:errors] << link
            end
          end
        rescue => e
          puts "[Scraper] Rescue error: #{e.inspect}"
        end
      end
      offset += 50
    end

    results
  end
end