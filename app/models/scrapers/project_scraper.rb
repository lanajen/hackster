class ProjectScraper
  include ScraperUtils

  attr_accessor :content, :page_url

  def self.scrape page_url
    s = new page_url

    # debug snippet
    # url = File.join(Rails.root, 'app/models/scrapers/test.html')
    # s = new 'https://community.spark.io/t/spark-controlled-halloween-costume/491'
    # s.content = s.read_file url
    # end debug snippet

    project = s.document.to_project
    project.website = page_url
    project
  end

  def document
    Document.new (content || scrape), @page_url, @strategy
  end

  def initialize page_url, strategy=nil
    @page_url = page_url.chomp('/')
    @strategy = strategy
  end

  def scrape
    @content = fetch_page @page_url
  end

  class Document
    include ScraperUtils

    DEFAULT_STRATEGY = :base
    KNOWN_GENERATORS = {
      'blogger' => :blogspot,
      'frontpage' => :base,
      'joomla' => :base,
      'wordpress' => :wordpress,
    }
    KNOWN_HOSTS = {
      'blogspot.fr' => :blogspot,
      'blogspot.com' => :blogspot,
      'forum.arduino.cc' => :arduinocc,
      'github.com' => :github,
      'instructables.com' => :instructable,
      'kickstarter.com' => :kickstarter,
      'medium.com' => :medium,
      'community.spark.io' => :spark_forum,
      'wordpress.com' => :wordpress,
    }

    def initialize content, page_url, strategy=nil
      @host = URI(page_url).host
      @parsed = Nokogiri::HTML(content)
      strategy ||= find_strategy_for_page_url(page_url)
      @scraper = "::ScraperStrategies::#{strategy.to_s.classify}".constantize.new(@parsed, page_url)
    end

    def to_project
      @scraper.to_project
    end

    private
      def find_strategy_for_page_url page_url
        KNOWN_HOSTS.each do |k,v|
          if k.in? @host
            return v
          end
        end if @host

        if generator = @parsed.at("meta[@name='generator']").try(:[], :content).try(:downcase)
          KNOWN_GENERATORS.each do |k,v|
            if k.in? generator
              return v
            end
          end
        end

        DEFAULT_STRATEGY
      end
  end
end