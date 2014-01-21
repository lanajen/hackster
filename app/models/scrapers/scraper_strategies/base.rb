module ScraperStrategies
  class Base
    LINK_REGEXP = {
      /123d\.circuits\.io/ => 'CircuitsioWidget.new(link:"|href|",name:"Schematics on Circuits.io")',
      /github\.com\/[0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+\z/ => 'GithubWidget.new(repo:"|href|",name:"Github repo")',
      /oshpark\.com\/shared_projects/ => 'OshparkWidget.new(link:"|href|",name:"PCB on OSH Park")',
      /tindie\.com/ => 'BuyWidget.new(link:"|href|",name:"Where to buy")',
      /upverter\.com/ => 'UpverterWidget.new(link:"|href|",name:"Schematics on Upverter")',
      /vimeo\.com/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /youtube\.com/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /youtu\.be/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
    }

    def initialize parsed
      @parsed = parsed
    end

    private
      def distribute_widgets
        widget_col = 1
        widget_row = 1
        count = 0
        @widgets.each do |widget|
          @project.widgets << widget
          widget.position = "#{widget_col}.#{widget_row}"
          if count.even?
            widget_col += 1
          else
            widget_row += 1
          end
          count += 1
        end
      end

      def normalize_image_link src
        src
      end

      def parse_images
        image_widget = ImageWidget.new name: 'Photos'
        @article.css('img').each_with_index do |img, i|
          image_widget.images.new(remote_file_url: normalize_image_link(img['src']), title: img['title'], position: i)
        end
        @widgets << image_widget if image_widget.images.any?

        if img = @article.at_css('img')
          @project.build_cover_image remote_file_url: normalize_image_link(img['src'])
        end
      end

      def parse_links
        {
          'a' => 'href',
          'iframe' => 'src',
        }.each do |el, attr|
          collection = []
          @article.css(el).each do |link|
            collection << link['href']
          end
          collection.uniq.each do |link|
            LINK_REGEXP.each do |regexp, command|
              if link =~ Regexp.new(regexp)
                command = command.gsub(/\|href\|/, link)
                widget = eval command
                @widgets << widget
                break
              end
            end
          end
        end
    end
  end
end