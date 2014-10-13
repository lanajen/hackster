class ProjectImportsController < ApplicationController
  before_filter :authenticate_user!

  def new
  end

  def create
    if urls_valid?(params[:urls])
      ScraperQueue.perform_async 'scrape_projects', params[:urls], params[:user_id].presence || current_user.id, params[:tech_tags_string]
      send_admin_message(true) unless current_user.is? :admin
      redirect_to root_path, notice: "We will start importing your projects soon. You'll receive an email when it's done."
    else
      flash.now[:alert] = @errors.join(' ')
      render action: 'new'
    end
  end

  private
    def send_admin_message notif=false
      @message = Message.new(
        from_email: current_user.email,
        message_type: 'generic'
      )
      @message.subject = "New import request"
      @message.subject = "[Notification] " + @message.subject if notif
      @message.body = "<p>Hi</p><p>Please import this project for me: <a href='#{params[:urls]}'>#{params[:urls]}</a>.</p>"
      @message.body += "<p>Tech tag: #{params[:tech_tags_string]}</p>" if params[:tech_tags_string].present?
      @message.body += "<p>Product tag: #{params[:product_tags_string]}</p>" if params[:product_tags_string].present?
      @message.body += "<p>Thanks!<br><a href='#{url_for(current_user)}'>#{current_user.name}</a></p><p><a href='http://#{APP_CONFIG['full_host']}/projects/imports/new?user_id=#{current_user.id}&urls=#{params[:urls]}'>Start importing</a></p>"
      BaseMailer.enqueue_generic_email(@message)
    end

    def urls_valid? urls
      @errors = []

      if urls.present?
        urls = urls.gsub(/\r\n/, ',').gsub(/\n/, ',').gsub(/[ ]+/, ',').split(',').reject{ |l| l.blank? }
        urls.each do |url|
          if url =~ /hackster\.io/
            @errors << "Looks like you're trying to import a page from Hackster? If you need help doing something please send us your query through the help widget in the bottom right corner of your screen (the question mark) or email us at team@hackster.io."
            break
          end
        end
      else
        @errors << "Please specify at least one page to import."
      end

      @errors.empty?
    end
end