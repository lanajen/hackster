# use a CSV to store all the data
# make interface to go through all articles and #1 find if I want them and #2 get the correct URL

class HackadayScraper
  include ScraperUtils

  # BASE_URL = 'http://hackaday.com/category/arduino-hacks'
  SLEEP_TIME = 1

  def extract_pages columns
    (1..@to_page).each do |page_number|
      file_name = get_file_name_from_url "#{@base_url}#{page_number}"
      content = read_file file_name
      next if content.blank?
      extract_to_csv content, columns
    end
    puts 'Done!'
  end

  def document content=nil
    Document.new(content)
  end

  def extract_to_csv content, columns
    document(content).to_csv columns
  end

  def fetch_pages
    (1..@to_page).each do |page_number|
      page_url = "#{@base_url}#{page_number}"
      fetch_and_write_page page_url

      puts "Sleeping for #{SLEEP_TIME} second..."
      sleep SLEEP_TIME
    end
  end

  def initialize base_url, to_page
    @base_url = base_url
    @to_page = to_page
  end

  class Document
    include ScraperUtils

    attr_accessor :title, :title_link, :body, :date, :links, :links_count, :authors, :tags

    def initialize content
      @parsed = Nokogiri::HTML(content)
    end

    def to_csv columns
      out = ''

      @parsed.css('#content .post').each do |post|
        title = post.at_css('h2 a').content
        title_link = post.at_css('h2 a').attributes['href'].value
        full_body = post.at_css('.entry-content').inner_html.gsub(/\"/, "'")
        body_text = post.at_css('.entry-content').inner_html.gsub(/\"/, "'").gsub(/<img[^>]+>/, '')
        body_image_link = post.at_css('.entry-content img')
        body_image_link = body_image_link.attributes['src'].value if body_image_link
        date = post.at_css('.post-info .date').attributes['title']

        links = post.css('.entry-content a').reduce({}) do |memo, a|
          memo[a.content] = a.attributes['href'].try(:value)
          memo
        end.reject{|k,v| v.nil? or v.match(/hackaday[\.]?com/) }
        first_link = links.values.first
        links_count = links.size
        links = links.map{|k,v| "#{k}: #{v}"}.join("\n")

        categories = post.css('.post-meta a').map{ |t| t.content }.join(',')

        authors = post.content.scan(/\[([^\s]+)\]/).flatten.uniq.join(',')

        columns.split(',').each do |column|
          raise "Column #{column} doesn't exist" unless defined?(column)
          out << "\"#{eval(column)}\""
          out << (columns.split(',').last == column ? "\r\n" : ',')
        end
      end

      header = "#{columns}\r\n"
      file_name = File.join(ROOT_DIR, 'csv', "#{Date.today}.csv")

      write_file file_name, out, header
    end
  end
end