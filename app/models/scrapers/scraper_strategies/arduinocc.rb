module ScraperStrategies
  class Arduinocc < Base
    def to_project
      puts 'Converting to project...'

      @project = Project.new private: true
      @widgets = []

      @article = @parsed.at_css('.post')

      @project.name = @parsed.at_css('.postSubject').text.strip

      parse_links
      parse_images
      parse_files
      parse_text

      distribute_widgets

      @project
    end
  end
end