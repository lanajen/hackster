class ProjectScraper
  include ScraperUtils

  DEFAULT_STRATEGY = :wordpress
  KNOWN_STRATEGIES = {
    'github.com' => :github,
    'wordpress.com' => :wordpress
  }

  attr_accessor :content, :page_url

  def self.scrape page_url
    s = new page_url#, :github
    # url = File.join(Rails.root, 'app/models/scrapers/maker.html')
    # s.content = s.read_file url

    project = s.document.to_project
    project.website = page_url
    project
  end

  def document
    Document.new (content || scrape), @strategy
  end

  def initialize page_url, strategy=nil
    @page_url = page_url
    @strategy = strategy || find_strategy_for_page_url(page_url)
  end

  def scrape
    @content = fetch_page @page_url
  end

  private
    def find_strategy_for_page_url page_url
      host = URI.parse(page_url).host
      if host.in? KNOWN_STRATEGIES
        KNOWN_STRATEGIES[host]
      else
        DEFAULT_STRATEGY
      end
    end

  class Document
    include ScraperUtils
    def initialize content, strategy
      @parsed = Nokogiri::HTML(content)
      @strategy = "::ScraperStrategies::#{strategy.to_s.classify}".constantize.new
    end

    def to_project
      @strategy.to_project(@parsed)
    end
  end
end