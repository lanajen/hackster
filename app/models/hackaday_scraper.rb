require 'nokogiri'
require 'open-uri'

module ScraperUtils
  def read_page file_name
    puts "Reading file #{file_name}..."
    File.open(file_name).read
  end

  def write_file file_name, content
    mode = (File.exists?(file_name) ? 'a' : 'w+')
    File.open(file_name, mode) do |file|
      file.syswrite content
      puts "Wrote #{file_name}"
    end
  end
end

# use a CSV to store all the data
# make interface to go through all articles and #1 find if I want them and #2 get the correct URL

class HackadayScraper
  include ScraperUtils

  BASE_URL = 'http://hackaday.com/category/arduino-hacks'
  SLEEP_TIME = 1

  def extract_pages to_page
    (1..to_page).each do |page_number|
      file_name = File.join(@html_dir, "#{page_number}.html")
      content = read_page file_name
      next if content.blank?
      extract_to_csv content, page_number
    end
  end

  def extract_to_csv content, page_number
    Document.new(content, @today_dir, page_number).to_csv
  end

  def fetch_page page_url
    puts "Fetching page #{page_url}..."
    page = open(page_url)
    content = page.read

    file_name = File.join(@html_dir, "#{page_number}.html")
    write_file file_name, content
  end

  def fetch_pages base_url, to_page
    (1..to_page).each do |page_number|
      page_url = "#{base_url}/page/#{page_number}"
      fetch_page page_url

      puts "Sleeping for #{SLEEP_TIME} second..."
      sleep SLEEP_TIME
    end
  end

  def initialize
    @root_dir = File.join(Rails.root, 'public', 'hackaday')
    Dir.mkdir @root_dir unless Dir.exists? @root_dir

    @today_dir = File.join(@root_dir, Date.today.to_s)
    Dir.mkdir @today_dir unless Dir.exists? @today_dir

    @html_dir = File.join(@today_dir, 'html')
    Dir.mkdir @html_dir unless Dir.exists? @html_dir

    csv_dir = File.join(@today_dir, 'csv')
    Dir.mkdir csv_dir unless Dir.exists? csv_dir

    mcsv_dir = File.join(@today_dir, 'mcsv')
    Dir.mkdir mcsv_dir unless Dir.exists? mcsv_dir
  end

  class Document
    include ScraperUtils

    attr_accessor :title, :title_link, :body, :date, :links, :links_count, :authors, :tags

    def initialize content, base_dir, page_number
      @base_dir = base_dir
      @parsed = Nokogiri::HTML(content)
      @page_number = page_number
    end

    def to_csv
      header = "title,title_link,body,date,categories,authors,links_count,links\r\n"
      out = header

      header = "title,title_link,body_text,body_image_link\r\n"
      mout = header

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
        links_count = links.size
        links = links.map{|k,v| "#{k}: #{v}"}.join("\n")

        categories = post.css('.post-meta a').map{ |t| t.content }.join(',')

        authors = post.content.scan(/\[([^\s]+)\]/).flatten.uniq.join(',')

        out << "\"#{title}\","
        out << "\"#{title_link}\","
        out << "\"#{full_body}\","
        out << "\"#{date}\","
        out << "\"#{categories}\","
        out << "\"#{authors}\","
        out << "\"#{links_count}\","
        out << "\"#{links}\"\r\n"

        if links_count <= 1
          puts "Skipping article #{title} at #{title_link}"
          next
        end

        mout << "\"#{title}\","
        mout << "\"#{title_link}\","
        mout << "\"#{body_text}\","
        mout << "\"#{body_image_link}\"\r\n"
      end

      file_name = File.join(@base_dir, 'csv', "#{@page_number}.csv")
      write_file file_name, out

      # file_name = File.join(@base_dir, 'mcsv', "#{@page_number}.csv")
      file_name = File.join(@base_dir, 'mcsv', "1.csv")
      write_file file_name, mout
    end
  end
end