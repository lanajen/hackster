class Api::V1::FlagsController < Api::V1::BaseController
  def create
    @flag = Flag.new params[:flag]

    if @flag.valid?
      @message = Message.new(
        message_type: 'generic'
      )
      @message.subject = "Content flagged for spam"
      @message.body = "<p>Hi<br><p>I would like to report the following as spam:<br>"
      @message.body += "<p>"
      @message.body += "#{@flag.flaggable_type}: #{@flag.flaggable_id}"
      @message.body += "</p>"
      if @flag.user
        @message.body += "<p>"
        @message.body += "Thanks, #{@flag.user.name} (#{@flag.user.user_name} / #{@flag.user.id})"
        @message.body += "</p>"
      end
      MailerQueue.enqueue_generic_email(@message)
      LogLine.create source: 'flag', log_type: 'flag', message: "#{@flag.flaggable_type}: #{@flag.flaggable_id} (by #{@flag.user}"

      render status: :ok, nothing: true

      track_event 'Flagged content', { flaggable_id: @flag.flaggable_id, flaggable_type: @flag.flaggable_type, user_id: @flag.user_id }
    else
      render json: { flag: @flag.errors }, status: :unprocessable_entity
    end
  end
end