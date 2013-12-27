module ScraperStrategies
  class Wordpress < Base
    def to_project parsed
      puts 'Converting to project...'

      project = Project.new private: true
      widgets = []

      article = parsed.at_css('article') || parsed.at_css('.post') || parsed

      {
        'a' => 'href',
        'iframe' => 'src',
      }.each do |el, attr|
        article.css(el).each do |link|
          LINK_REGEXP.each do |regexp, command|
            if link[attr] =~ Regexp.new(regexp)
              command.gsub!(/\|href\|/, link[attr])
              widget = eval command
              widgets << widget
              break
            end
          end
        end
      end

      project.name = article.at_css('.entry-title').try(:text) || article.css('h1').last.try(:text) || article.at_css('h2').try(:text) || parsed.title

      tags = article.css('[rel=category]') + article.css('[rel=tag]') + article.css('[rel="category tag"]')
      project.product_tags_string = tags.map{|a| a.text }.join(',')

      project, widgets = parse_images(article, project, widgets)

      # article.at_css('.entry-content').try(:inner_html) ||  # includes share tools
      raw_text = article.css('p').map{|p| p.to_html }.join('')
      sanitized_text = Sanitize.clean(raw_text, Sanitize::Config::BASIC)
      text = Nokogiri::HTML(sanitized_text)
      text.css('a').find_all.each{|el| el.remove if el.content.strip.blank? }
      text.css('p').find_all.each{|el| el.remove if el.content.strip.blank? }
      text = Sanitize.clean(text.to_html, Sanitize::Config::BASIC)
      widgets << TextWidget.new(content: text, name: 'About')

      widget_col = 1
      widget_row = 1
      count = 0
      widgets.each do |widget|
        project.widgets << widget
        widget.position = "#{widget_col}.#{widget_row}"
        if count.even?
          widget_col += 1
        else
          widget_row += 1
        end
        count += 1
      end

      if comment_dom = parsed.at_css('#comments')
        depth = 1
        project = extract_comments comment_dom, project
      end

      project
    end

    def extract_comments dom, project, depth=1, parent=nil
      dom.css("li.depth-#{depth}").each do |comment|
        body = comment.at_css('.comment-content').inner_html
        name = comment.at_css('.comment-author .fn').text
        created_at = DateTime.parse comment.at_css('time')['datetime']
        c = project.comments.new body: body, guest_name: name
        c.created_at = created_at
        c.parent = parent
        c.disable_notification!
        project = extract_comments comment, project, depth+1, c
      end
      project
    end
  end
end