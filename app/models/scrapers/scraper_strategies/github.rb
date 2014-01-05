module ScraperStrategies
  class Github < Base
    def to_project parsed
      puts 'Converting to project...'

      project = Project.new private: true
      widgets = []

      article = parsed.at_css('article') || parsed

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

      project.name = parsed.at_css('h1 strong').text.strip
      project.one_liner = parsed.at_css('.repository-description').try(:text).try(:strip)
      project.website = parsed.at_css('.repository-website').try(:text).try(:strip)

      github_link = "https://github.com#{parsed.at_css('h1 strong a')['href']}"
      widgets << GithubWidget.new(repo: github_link, name: 'Github repo')

      project, widgets = parse_images(article, project, widgets)

      text_blocks = article.inner_html.split(/<h[1-2]>/).reject{|t| t.blank? }.map do |t|
        if t.match(/<\/(h[1-2])>/)
          '<' + $1 + '>' + t
        else
          t
        end
      end.map do |t|
        n = Nokogiri::HTML(t)
        if t = n.at_css('h1') || n.at_css('h2')
          el = t
          t = t.text.strip
          el.remove
        end
        n.css('a').find_all.each{|el| el.remove if el.content.strip.blank? }
        n.css('p').find_all.each{|el| el.remove if el.content.strip.blank? }
        p = Sanitize.clean(n.to_html, Sanitize::Config::BASIC_BLANK).strip
        [t, p]
      end.reject{|t| t[1].blank? }
      text_blocks.each do |t|
        widgets << TextWidget.new(content: t[1], name: t[0] || 'About')
      end

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
  end
end