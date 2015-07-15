class QuotesController < ApplicationController
  def create
    @quote = Quote.new params[:quote]

    if @quote.valid?
      @message = Message.new(
        from_email: @quote.email,
        message_type: 'generic'
      )
      @message.subject = "New components quote request"
      @message.recipients = 'ben@hackster.io'
      @message.body = "<p>Hi<br><p>I would like to receive a quote for the following:<br>"
      @message.body += "<p>"
      @message.body += "<b>Project: </b><a href='#{project_url(@quote.project)}'>#{@quote.project.name}</a><br>"
      @message.body += "<b>Email: </b>#{@quote.email}<br>"
      @message.body += "<b>Country: </b>#{@quote.country}<br>"
      @message.body += "</p>"
      @message.body += "<p><b>Components: </b></p>"
      @message.body += "<ul>"
      @quote.components.each do |component|
        @message.body += '<li>' + component + '</li>'
      end
      @message.body += "</ul>"
      MailerQueue.enqueue_generic_email(@message)
      LogLine.create source: 'quote', log_type: 'quote', message: @message.body

      session[:share_modal] = 'buy_all_quote_confirm'
      session[:share_modal_model] = 'project'
      session[:share_modal_model_id] = @quote.project_id

      render status: :ok, nothing: true

      track_event 'Requested a quote', { project_id: @quote.project_id, components_count: (@quote.components.size - 1), country: @quote.country }
    else
      track_event 'Requested a quote', { project_id: @quote.project_id, components_count: (@quote.components.size - 1), country: @quote.country } if @quote.errors.count == 1 and @quote.errors[:country] and @quote.country.present?

      render json: { quote: @quote.errors }, status: :unprocessable_entity
    end
  end
end