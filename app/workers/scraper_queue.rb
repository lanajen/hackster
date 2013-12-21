class ScraperQueue < BaseWorker
  @queue = :scraper

  def scrape_project page_url, user_id
    @message = Message.new(
      to_email: User.find(user_id).email,
      message_type: 'generic'
    )

    project = ProjectScraper.scrape page_url
    project.build_team
    project.team.members.new(user_id: user_id)
    project.save
    @message.subject = "#{project.name} has been imported to your Hackster.io profile"
    @message.body = "<p>Hi</p><p>This is to let you know that <a href='http://www.#{APP_CONFIG['full_host']}/projects/#{project.to_param}'>#{project.name}</a> has been successfully imported.</p><p>You can update it and make it public at <a href='http://www.#{APP_CONFIG['full_host']}/projects/#{project.to_param}'>http://www.#{APP_CONFIG['full_host']}/projects/#{project.to_param}</a>.</p><p>Cheers<br/>The Hackster.io team</p>"

  rescue => exception
    @message.subject = "Your project couldn't be imported"
    @message.body = "<p>Hi</p><p>This is to let you know that we couldn't import your page: #{page_url}.</p><p>We've been notified and will try to fix it. We'll keep you updated.</p><p>Cheers<br/>The Hackster.io team</p>"

    clean_backtrace = Rails.backtrace_cleaner.clean(exception.backtrace)
    message = "#{exception.inspect} // backtrace: #{clean_backtrace.join(' - ')} // page_url: #{page_url} // user_id: #{user_id}"
    log_line = LogLine.create(message: message, log_type: 'error', source: 'project_scraper')
    logger = Rails.logger
    logger.error ""
    logger.error "Exception: #{exception.inspect}"
    logger.error ""
    clean_backtrace.each { |line| logger.error "Backtrace: " + line }
    logger.error ""
    BaseMailer.enqueue_email 'error_notification', { context_type: :log_line, context_id: log_line.id }

  ensure
    BaseMailer.enqueue_generic_email(@message)
  end
end