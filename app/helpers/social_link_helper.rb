module SocialLinkHelper
  def facebook_share link, name, description, picture
    out = 'https://www.facebook.com/dialog/feed?app_id=543757942384158'
    out += '&link=' + CGI.escape(link)
    out += '&name=' + CGI.escape(name)
    out += '&description=' + CGI.escape(description)
    out += '&picture=' + CGI.escape(picture) if picture
    out += '&redirect_uri=' + CGI.escape('http://facebook.com')
    out
  end

  def googleplus_share url
    out = 'https://plus.google.com/share?'
    out += 'url=' + CGI.escape(url)
    out
  end

  def linkedin_share url, title, summary
    out = 'https://www.linkedin.com/shareArticle?mini=true'
    out += '&url=' + CGI.escape(url)
    out += '&title=' + CGI.escape(title)
    out += '&summary=' + CGI.escape(summary)
    out += '&source=' + CGI.escape('http://www.hackster.io')
    out
  end

  def reddit_share url, title
    out = 'http://reddit.com/submit?'
    out += 'url=' + CGI.escape(url)
    out += '&title=' + CGI.escape(title)
    out
  end

  def twitter_share url, text
    out = 'https://twitter.com/intent/tweet?'
    out += 'text=' + CGI.escape(text)
    out += '&url=' + CGI.escape(url)
    # out += '&via=hacksterio'
    out
  end
end