class InstructablesScraper
  attr_accessor :tech

  def self.scrape_in_bulk teches
    # teches = ['Raspberry Pi', 'Arduino', 'Spark Core', 'Electric Imp', 'Teensy', 'Digispark', 'BeagleBoard', 'Intel Galileo', 'Pebble', 'pcDuino', 'TI Launchpad']
    results = {}

    teches.each do |tech|
      results[tech] = new(tech).scrape
    end

    results
  end

  def initialize tech
    @tech = tech
  end

  def scrape
    puts "Scraping instructables.com for #{tech}"
    offset = 0
    results = { errors: [], successes: 0, skips: 0 }

    while true do
      p=ProjectScraper.new "http://www.instructables.com/tag/type-id/category-technology/?sort=none&partial=true&q=#{CGI.escape(tech)}&count=50&offset=#{offset}&page=1&sort=RECENT"
      parsed = Nokogiri::HTML p.scrape
      lis = parsed.css('li')
      break if lis.empty?
      lis.each do |li|
        name = li.at_css('.title').text.strip
        author = li.at_css('.author').text.gsub(/by/, '').strip
        link = 'http://www.instructables.com' + li.at_css('.title a')['href']
        next unless li.at_css('.views')
        if project = Project.find_by_website(link)
          puts "Found existing project on instructables.com: #{link}"
          if project.external
            project.tech_tags_string += ",#{tech}" unless project.tech_tags_string =~ Regexp.new(tech)
            project.save
          end
          results[:skips] += 1
        else
          puts "Scraping project in #{tech}: #{name} at #{link}"
          image = li.at_css('img')['src'].gsub(/RECTANGLE1/, 'LARGE')
          project = Project.new name: name, guest_name: author, website: link, one_liner: name, tech_tags_string: tech
          project.build_cover_image
          project.cover_image.remote_file_url = image
          project.external = true
          if project.save
            results[:successes] += 1
          else
            results[:errors] << link
          end
        end
      end
      offset += 50
    end

    results
  end
end