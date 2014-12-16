class DragonQueriesController < ApplicationController
  # def index
  #   title "Get help manufacturing products"
  # end

  def new
    title "Start working with Dragon Innovation"
    @dragon_query = DragonQuery.new
  end

  def create
    @dragon_query = DragonQuery.new params[:dragon_query]

    if @dragon_query.valid?
      @message = Message.new(
        from_email: @dragon_query.email,
        message_type: 'generic'
      )
      @message.recipients = 'ben@hackster.io,adam@hackster.io'
      @message.subject = "New Dragon certification request"
      @message.body = '<p>The following should be added to a CSV file to be given to Dragon:</p><p>' + @dragon_query.to_csv.gsub(/\n/, '<br>') + '</p>'
      @message.body += "<p>Thanks!<br><a href='#{url_for(current_user)}'>#{current_user.name}</a><br>" if user_signed_in?
      BaseMailer.enqueue_generic_email(@message)
      LogLine.create source: 'dragon_query', log_type: 'dragon_query', message: @message.body

      redirect_to root_path, notice: "Thanks for your query, Dragon will be in touch soon!"
    else
      render 'new'
    end
  end
end