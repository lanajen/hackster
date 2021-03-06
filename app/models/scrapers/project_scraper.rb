class ProjectScraper
  include ScraperUtils

  attr_accessor :content, :page_url

  def self.scrape page_url, options={}
    s = new page_url

    # debug snippet
    # url = File.join(Rails.root, 'app/models/scrapers/test.html')
    # s = new 'http://hackaday.io/project/1998-Portable-Chaos-Monkey'
    # s.content = s.read_file url
    # end debug snippet

    project = s.document.to_project options[:model_class]
    project.website ||= options[:website].presence || page_url
    project.pryvate = (options[:private].nil? ? true : options[:private])
    project.workflow_state = options[:workflow_state]
    project.name = project.name[0..59]
    project.extract_toc!
    project
  end

  def self.scrape_and_save page_url, user_id=1, options={}
    project = scrape page_url, options
    project.build_team
    project.team.members.new user_id: user_id
    project.save
    project.build_logs.each{|p| p.draft = false; p.save }
    project.update_counters
    project
  end

  def document
    Document.new (content || scrape), @page_url, @strategy
  end

  def initialize page_url, strategy=nil
    @page_url = page_url#.chomp('/')
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
      'discourse' => :discourse,
      'frontpage' => :base,
      'joomla' => :base,
      'mediawiki' => :mediawiki,
      'wordpress' => :wordpress,
    }
    KNOWN_HOSTS = {
      '123d.circuits.io' => :autodesk_circuit,
      '1sheeld.com' => :onesheeld,
      'iot-hackseries.s3-website-us-west-2.amazonaws.com' => :aws_hackday,
      'bareconductive.com' => :bareconductive,
      'blogspot.com' => :blogspot,
      'blogspot.fr' => :blogspot,
      'challengepost.com' => :challengepost,
      'codebender.cc' => :codebender,
      'community.particle.io' => :particle_forum,
      'cypress.com' => :cypress_blog,
      'developer.mbed.org' => :mbed,
      'devpost.com' => :challengepost,
      'forum.arduino.cc' => :arduino_forum,
      'fusion360.autodesk.com' => :fusion360,
      'github.com' => :github,
      'hackaday.io' => :hackadayio,
      'instructables.com' => :instructable,
      'littlebits.cc' => :littlebit,
      'kickstarter.com' => :kickstarter,
      'makezine.com' => :makezine,
      'medium.com' => :medium,
      'pubnub.com' => :pubnub,
      'scuola.arduino.cc' => :arduino_scuola,
      'seeedstudio.com' => :seeed,
      'e2e.ti.com' => :tie2e,
      'udoo.org' => :udoo,
      'wordpress.com' => :wordpress,
      'youtube.com' => :youtube,
    }

    def initialize content, page_url, strategy=nil
      @host = URI(page_url).host
      @parsed = Nokogiri::HTML(content)
      strategy ||= find_strategy_for_page_url(page_url)
      @scraper = "::ScraperStrategies::#{strategy.to_s.classify}".constantize.new(@parsed, page_url)
    end

    def to_project model_class=nil
      @scraper.to_project model_class
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