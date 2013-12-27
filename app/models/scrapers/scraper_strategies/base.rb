module ScraperStrategies
  class Base
    LINK_REGEXP = {
      /github\.com/ => 'GithubWidget.new(repo:"|href|",name:"Github repo")',
      # /oshpark\.com/ => 'GithubWidget',
      /upverter\.com/ => 'UpverterWidget.new(link:"|href|",name:"Schematics on Upverter")',
      /youtube\.com/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /youtu\.be/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /vimeo\.com/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /tindie\.com/ => 'BuyWidget.new(link:"|href|",name:"Where to buy")',
    }

    private
      def parse_images article, project, widgets
        image_widget = ImageWidget.new name: 'Photos'
        article.css('img').each_with_index do |img, i|
          image_widget.images.new(remote_file_url: img['src'], title: img['title'], position: i)
        end
        widgets << image_widget if image_widget.images.any?

        if img = article.at_css('img')
          project.build_cover_image remote_file_url: img['src']
        end

        return project, widgets
      end
  end
end