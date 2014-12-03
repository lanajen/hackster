class ScraperQueue < BaseWorker
  TECHES_TO_SCRAPE = ['Raspberry Pi', 'Arduino', 'Spark Core', 'Electric Imp', 'Teensy', 'Digispark', 'BeagleBoard', 'Intel Galileo', 'Pebble', 'pcDuino', 'TI Launchpad']
  # @queue = :scraper
  sidekiq_options queue: :low, retry: 0

  def scrape_instructables platforms=TECHES_TO_SCRAPE
    @results = InstructablesScraper.scrape_in_bulk platforms

    @message = Message.new(
      message_type: 'generic',
    )
    @message.subject = "Results for instructables.com import"
    @message.body = "<p>#{@results.size} platforms were imported:</p>"
    @results.each do |platform, results|
      @message.body += "<p><b>#{platform}: #{results[:errors].size} errors, #{results[:successes]} successes, #{results[:skips]} skips</p>"
    end
    BaseMailer.enqueue_generic_email(@message)

  rescue => e
    clean_backtrace = Rails.backtrace_cleaner.clean(e.backtrace)
    message = "Scrape instructables.com error: #{e.inspect} // backtrace: #{clean_backtrace.join(' - ')} // Results: #{@results.inspect}"
    log_error e, clean_backtrace, message
  end

  def scrape_project page_url, user_id, platform_tags_string=nil
    @message = Message.new(
      to_email: User.find(user_id).email,
      message_type: 'generic'
    )

    if page_url =~ /hackster\.io/
      @message.subject = "A page couldn't be imported"
      @message.body = "<p>Hi</p><p>This is to let you know that we couldn't import <a href='#{page_url}'>the page you asked us to</a> because it's part of our website. We invite you to try importing a page from an external website instead.</p><p>If you need any help please do not hesitate to reply to that email and ask us directly.</p><p>Cheers<br/>The Hackster.io team</p>"
    else
      page_url += '?ALLSTEPS' if page_url =~ /instructables\.com/ and !(page_url =~ /\?ALLSTEPS\Z/)  # get all the steps from instructables.com
      if Project.where(website: page_url).empty?
        @project = ProjectScraper.scrape page_url
        @project.build_team
        @project.team.members.new(user_id: user_id)
        @project.build_logs.each{|p| p.user_id = user_id }
        @project.platform_tags_string = platform_tags_string if platform_tags_string.present?
        messages = @project.errors.messages.map{|k,v| "#{k} #{v.to_sentence};" }
        raise ScrapeError, "Couldn't save project because #{messages.to_sentence}" unless @project.save
        @project.build_logs.each{|p| p.draft = false; p.save }
        @project.update_counters
        @message.subject = "#{@project.name} has been imported to your Hackster.io profile"
        @message.body = "<p>Hi</p><p>This is to let you know that <a href='http://#{APP_CONFIG['full_host']}/projects/#{@project.to_param}'>#{@project.name}</a> has been successfully imported from <a href='#{page_url}'>#{page_url}</a>.</p><p>You can update it and make it public at <a href='http://#{APP_CONFIG['full_host']}/projects/#{@project.to_param}'>http://#{APP_CONFIG['full_host']}/projects/#{@project.to_param}</a>.</p><p><b>Please note:</b> our importer is an experimental feature, your project might need some additional editing before it's ready for prime!</p><p>Cheers<br/>The Hackster.io team</p>"
      else
        @message.subject = "Project already imported"
        @message.body = "<p>Hi</p><p>This is to let you know that we didn't import <a href='#{page_url}'>the page you asked us to</a> because it has already been imported. We invite you to try importing a different page instead.</p><p>If you need any help please do not hesitate to reply to that email and ask us directly.</p><p>Cheers<br/>The Hackster.io team</p>"
      end
    end

    BaseMailer.enqueue_generic_email(@message)

  rescue => exception
    @message.subject = "Your project couldn't be imported"
    @message.body = "<p>Hi</p><p>This is to let you know that we couldn't import your page: #{page_url}.</p><p>We've been notified and will try to fix it. We'll keep you updated.</p><p>Cheers<br/>The Hackster.io team</p>"

    clean_backtrace = Rails.backtrace_cleaner.clean(exception.backtrace)
    message = "Project import error: #{exception.inspect} // backtrace: #{clean_backtrace.join(' - ')} // page_url: #{page_url} // user_id: #{user_id} // project_errors: #{@project.try(:errors).try(:messages)}"
    log_error exception, clean_backtrace, message

  ensure
    BaseMailer.enqueue_generic_email(@message)
  end

  def scrape_projects page_urls, user_id, platform_tags_string=nil
    urls = page_urls.gsub(/\r\n/, ',').gsub(/\n/, ',').gsub(/[ ]+/, ',').split(',').reject{ |l| l.blank? }
    urls.each do |url|
      self.class.perform_async 'scrape_project', url, user_id, platform_tags_string
    end
  end

  private
    def log_error exception, clean_backtrace, message
      log_line = LogLine.create(message: message, log_type: 'error', source: 'scraper_queue')
      logger = Rails.logger
      logger.error ""
      logger.error "Exception: #{exception.inspect}"
      logger.error ""
      clean_backtrace.each { |line| logger.error "Backtrace: " + line }
      logger.error ""
      BaseMailer.enqueue_email 'error_notification', { context_type: :log_line, context_id: log_line.id }
    end

  class ScrapeError < StandardError
  end
end