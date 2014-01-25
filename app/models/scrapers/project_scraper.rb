class ProjectScraper
  include ScraperUtils

  DEFAULT_STRATEGY = :base
  KNOWN_STRATEGIES = {
    'blogspot.fr' => :blogspot,
    'blogspot.com' => :blogspot,
    'github.com' => :github,
    'wordpress.com' => :wordpress,
  }

  attr_accessor :content, :page_url

  def self.scrape page_url
    s = new page_url

    # debug snippet
    # url = File.join(Rails.root, 'app/models/scrapers/maker.html')
    # s = new 'http://www.artbottoys.com', :base
    # s.content = s.read_file url
    # end debug snippet

    project = s.document.to_project
    project.website = page_url
    project
  end

  def document
    Document.new (content || scrape), @strategy, @page_url
  end

  def initialize page_url, strategy=nil
    @page_url = page_url.chomp('/')
    @host = URI(page_url).host
    @strategy = strategy || find_strategy_for_page_url(page_url)
  end

  def scrape
    @content = fetch_page @page_url
  end

  private
    def find_strategy_for_page_url page_url
      return DEFAULT_STRATEGY unless @host

      KNOWN_STRATEGIES.each do |k,v|
        if k.in? @host
          return v
        end
      end
      DEFAULT_STRATEGY
    end

  class Document
    include ScraperUtils
    def initialize content, strategy, page_url
      @parsed = Nokogiri::HTML(content)
      @strategy = "::ScraperStrategies::#{strategy.to_s.classify}".constantize.new(@parsed, page_url)
    end

    def to_project
      @strategy.to_project
    end
  end
end