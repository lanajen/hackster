require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'
require 'uri'

module ScraperUtils
  ROOT_DIR = File.join(Rails.root, 'public', 'scraper')

  def delete_file file_name
    File.delete file_name if File.exists? file_name
  end

  def fetch_page page_url, file_name=nil
    page_url = 'http://' + page_url unless page_url =~ /^https?\:\/\//
    puts "Fetching page #{page_url}..."
    5.times do
      begin
        return open(page_url, allow_redirections: :safe, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
      rescue => e
        # raise e.inspect
        puts "Failed opening #{page_url}. Retrying in 1 second..."
        sleep 1
      end
    end
    raise "Failed opening page #{page_url} after 5 tries."
  end

  def fetch_and_write_page page_url, file_name=nil
    content = fetch_page page_url, file_name

    file_name ||= get_file_name_from_url page_url

    write_file file_name, content if file_name
  end

  def get_file_name_from_url url, date=Date.today.to_s
    file_name = File.join(ROOT_DIR, date, "#{url.gsub(/http(s)?\:\/\//, '')}.html")
    make_directories_for file_name
    file_name
  end

  def make_directories_for file_name
    current_dir = '/'
    file_name.split('/')[1..-2].each do |dir|
      current_dir = File.join(current_dir, dir)
      Dir.mkdir current_dir unless Dir.exists? current_dir
    end
  end

  def read_file file_name
    puts "Reading file #{file_name}..."
    File.open(file_name).read
  end

  def test_link link
    u = URI.parse link
    print "Testing link #{link}... "
    begin
      http = Net::HTTP.new(u.host, u.port)
      if u.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      status_code = http.request_head(u.request_uri).code
    rescue
      status_code = "Error"
    end
    puts "#{status_code}"
    status_code.in? %w(200 301 302)
  end

  def write_file file_name, content, header=nil, mode=nil
    mode ||= (File.exists?(file_name) ? 'a' : 'w+')
    content = header + content if header and mode == 'w+'
    File.open(file_name, mode) do |file|
      file.syswrite content
      output = (mode == 'w+' ? 'Wrote' : 'Appended')
      puts "#{output} to #{file_name}"
    end
  end
end