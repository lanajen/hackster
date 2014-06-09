Monologue::User.class_eval do
  self.table_name = 'users'
end

Monologue.config do |config|
  config.site_name = "Hackster.io's blog"
  config.site_subtitle = "my own place online"
  config.site_url = "http://www.hackster.io/blog"

  config.meta_description = "Thoughts and resources about hardware hacking for makers."
  config.meta_keyword = "hardware,hacks,makers,projects"

  config.admin_force_ssl = false
  config.posts_per_page = 10

  config.disqus_shortname = "hacksterio"

  # LOCALE
  config.twitter_locale = "en" # "fr"
  config.facebook_like_locale = "en_US" # "fr_CA"
  config.google_plusone_locale = "en"

  # config.layout               = "layouts/application"

  # ANALYTICS
  # config.gauge_analytics_site_id = "YOUR COGE FROM GAUG.ES"
  config.google_analytics_id = "UA-11926897-15"

  config.sidebar = ["latest_posts", "latest_tweets", "categories", "tag_cloud"]


  #SOCIAL
  config.twitter_username = "hacksterio"
  config.facebook_url = "https://www.facebook.com/hacksterio"
  # config.facebook_logo = 'logo.png'
  # config.google_plus_account_url = "https://plus.google.com/u/1/115273180419164295760/posts"
  # config.linkedin_url = "http://www.linkedin.com/in/jipiboily"
  # config.github_username = "jipiboily"
  config.show_rss_icon = false

end